#!/bin/bash
if [ $# -eq 0 ]
then
    NR_JOBS=""
    CATKIN_JOBS=""
else
    NR_JOBS=${1:-}
    CATKIN_JOBS="-j${NR_JOBS}"
fi

FILEDIR=$(readlink -f ${BASH_SOURCE})
BASEDIR=$(dirname ${FILEDIR})
# BASEDIR is ??/<ws_name>/src/covins
echo "File directory: ${BASEDIR}"
cd ${BASEDIR}/..
wstool init
wstool merge covins/dependencies.rosinstall
wstool up
chmod +x covins/fix_eigen_deps.sh
./covins/fix_eigen_deps.sh

set -e
cd ${BASEDIR}/../..
catkin build ${CATKIN_JOBS} eigen_catkin opencv3_catkin
cd ${BASEDIR}/../..
source devel/setup.bash

cd ${BASEDIR}/covins_backend/
#DBoW2
cd thirdparty/DBoW2
if [ ! -d "build" ]
then
  mkdir build
  cd build
  cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo
  make -j${NR_JOBS}
fi

cd ${BASEDIR}/../..
catkin build ${CATKIN_JOBS} covins_backend

#Extract vocabulary
cd ${BASEDIR}/covins_backend/
cd config
if [ ! -f "ORBvoc.txt" ]
then
  unzip ORBvoc.txt.zip
fi

cd ${BASEDIR}/../..
source devel/setup.bash

cd ${BASEDIR}/../pangolin
if [ ! -d "build" ]
then
  mkdir build
  cd build
  cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo
  make -j${NR_JOBS}
fi

cd ${BASEDIR}/orb_slam3/Thirdparty/DBoW2
if [ ! -d "build" ]
then
  mkdir build
  cd build
  cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo
  make -j${NR_JOBS}
fi

cd ${BASEDIR}/orb_slam3/Thirdparty/g2o
if [ ! -d "build" ]
then
  mkdir build
  cd build
  cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo
  make -j${NR_JOBS}
fi

cd ${BASEDIR}/orb_slam3/Vocabulary
if [ ! -f "ORBvoc.txt" ]
then
  tar -xf ORBvoc.txt.tar.gz
fi

cd ${BASEDIR}/orb_slam3
if [ ! -d "build" ]
then
  mkdir build
fi
cd build
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo
make -j${NR_JOBS}

#finish
exit 0
