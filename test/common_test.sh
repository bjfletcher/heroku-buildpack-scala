#!/usr/bin/env bash

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh
. ${BUILDPACK_HOME}/bin/common

EXPECTED_VERSION=0.11.3

testGetSbtVersionFileMissing()
{  
  capture get_supported_sbt_version ${BUILD_DIR}/project/build.properties

  assertCapturedSuccess
  assertCapturedEquals ""
}

testGetSbtVersionMissing()
{  
  mkdir -p ${BUILD_DIR}/project
  cat > ${BUILD_DIR}/project/build.properties <<EOF
some.prop=1.2.3
EOF

  capture get_supported_sbt_version ${BUILD_DIR}/project/build.properties

  assertCapturedSuccess
  assertCapturedEquals ""
}

testGetSbtVersionOnSingleLine_Unix()
{  
  mkdir -p ${BUILD_DIR}/project
  cat > ${BUILD_DIR}/project/build.properties <<EOF
sbt.version=${EXPECTED_VERSION}
EOF
  assertEquals "Precondition: Should be a UNIX file" "ASCII text" "$(file -b ${BUILD_DIR}/project/build.properties)"

  capture get_supported_sbt_version ${BUILD_DIR}/project/build.properties

  assertCapturedSuccess
  assertCapturedEquals "${EXPECTED_VERSION}"
}

testGetSbtVersionOnMutipleLines_Unix()
{  
  mkdir -p ${BUILD_DIR}/project
  cat > ${BUILD_DIR}/project/build.properties <<EOF
something.before= 0.0.0
sbt.version=${EXPECTED_VERSION}
something.after=1.2.3
EOF
  assertEquals "Precondition: Should be a UNIX file" "ASCII text" "$(file -b ${BUILD_DIR}/project/build.properties)"

  capture get_supported_sbt_version ${BUILD_DIR}/project/build.properties
  
  assertCapturedSuccess
  assertCapturedEquals "${EXPECTED_VERSION}"
}


testGetSbtVersionOnSingleLine_Windows()
{  
  mkdir -p ${BUILD_DIR}/project
  sed -e 's/$/\r/' > ${BUILD_DIR}/project/build.properties <<EOF
sbt.version=${EXPECTED_VERSION}
EOF
  assertEquals "Precondition: Should be a Windows file" "ASCII text, with CRLF line terminators" "$(file -b ${BUILD_DIR}/project/build.properties)"

  capture get_supported_sbt_version ${BUILD_DIR}/project/build.properties
  
  assertCapturedSuccess
  assertCapturedEquals "${EXPECTED_VERSION}"
}

testGetSbtVersionOnMutipleLines_Windows()
{  
  mkdir -p ${BUILD_DIR}/project
  sed -e 's/$/\r/' > ${BUILD_DIR}/project/build.properties <<EOF
something.before=1.2.3
sbt.version=${EXPECTED_VERSION}
something.after=2.2.2
EOF
  assertEquals "Precondition: Should be a Windows file" "ASCII text, with CRLF line terminators" "$(file -b ${BUILD_DIR}/project/build.properties)"

  capture get_supported_sbt_version ${BUILD_DIR}/project/build.properties

  assertCapturedSuccess
  assertCapturedEquals "${EXPECTED_VERSION}"
}

testGetSbtVersionWithSpaces()
{
  mkdir -p ${BUILD_DIR}/project
  cat > ${BUILD_DIR}/project/build.properties <<EOF
sbt.version   =    ${EXPECTED_VERSION}    
EOF

  capture get_supported_sbt_version ${BUILD_DIR}/project/build.properties

  assertCapturedSuccess
  assertCapturedEquals "${EXPECTED_VERSION}"
}

testGetSbtVersionWithTabs()
{
  mkdir -p ${BUILD_DIR}/project
  sed -e 's/ /\t/g' > ${BUILD_DIR}/project/build.properties <<EOF
sbt.version   =    ${EXPECTED_VERSION}    
EOF

  capture get_supported_sbt_version ${BUILD_DIR}/project/build.properties

  assertCapturedSuccess
  assertCapturedEquals "${EXPECTED_VERSION}"
}

testGetSbtVersionWithTrailingLetters()
{
  mkdir -p ${BUILD_DIR}/project
  cat > ${BUILD_DIR}/project/build.properties <<EOF
sbt.version   =    ${EXPECTED_VERSION}RC    
EOF

  capture get_supported_sbt_version ${BUILD_DIR}/project/build.properties

  assertCapturedSuccess
  assertCapturedEquals ""
}

testGetSbtVersionWithNoSpaces() {
  mkdir -p ${BUILD_DIR}/project
  cat > ${BUILD_DIR}/project/build.properties <<EOF
sbt.version${EXPECTED_VERSION}    
EOF
  capture get_supported_sbt_version ${BUILD_DIR}/project/build.properties
  assertCapturedSuccess
  assertCapturedEquals ""
}

testGetSbtVersionWithNoValue() {
  mkdir -p ${BUILD_DIR}/project
  cat > ${BUILD_DIR}/project/build.properties <<EOF
sbt.version=
EOF
  capture get_supported_sbt_version ${BUILD_DIR}/project/build.properties
  assertCapturedSuccess
  assertCapturedEquals ""
}

testGetPlayVersionWithSimilarNames() {
  mkdir -p ${BUILD_DIR}/project
  cat > ${BUILD_DIR}/project/build.properties <<EOF
sbts.version=0.11.0
sbt.vversion=0.11.0
sbt.version=${EXPECTED_VERSION}
EOF
  capture get_supported_sbt_version ${BUILD_DIR}/project/build.properties
  assertCapturedSuccess
  assertCapturedEquals "${EXPECTED_VERSION}"
}

testGetPlayVersionWithSimilarNameReverseOrder() {
  mkdir -p ${BUILD_DIR}/project
  cat > ${BUILD_DIR}/project/build.properties <<EOF
sbt.version=${EXPECTED_VERSION}
sbts.version=0.11.0
sbt.vversion=0.11.0
EOF
  capture get_supported_sbt_version ${BUILD_DIR}/project/build.properties
  assertCapturedSuccess
  assertCapturedEquals "${EXPECTED_VERSION}"
}