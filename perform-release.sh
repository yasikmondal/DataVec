#!/bin/bash
set -eu

if [[ $# < 3 ]]; then
    echo "Usage: bash perform-release.sh release_version snapshot_version staging_repository"
    exit 1
fi

RELEASE_VERSION=$1
SNAPSHOT_VERSION=$2
STAGING_REPOSITORY=$3

echo "Releasing version $RELEASE_VERSION ($SNAPSHOT_VERSION) to repository $STAGING_REPOSITORY"
echo "========================================================================================"

if [[ ! -z $(git tag -l "datavec-$RELEASE_VERSION") ]]; then
    echo "Error: Version $RELEASE_VERSION has already been released!"
    exit 1
fi

sed -i "s/<nd4j.version>.*<\/nd4j.version>/<nd4j.version>$RELEASE_VERSION<\/nd4j.version>/" pom.xml
#Spark versions, like <version>xxx_spark_2-SNAPSHOT</version>
for f in $(find . -name 'pom.xml' -not -path '*target*'); do
    sed -i "s/version>.*_spark_.*</version>${RELEASE_VERSION}_spark_1</g" $f
done
mvn versions:set -DallowSnapshots=true -DgenerateBackupPoms=false -DnewVersion=$RELEASE_VERSION

mvn clean deploy -Dgpg.executable=gpg2 -DperformRelease -Psonatype-oss-release -DskipTests -DstagingRepositoryId=$STAGING_REPOSITORY
source change-spark-versions.sh 2
mvn clean deploy -Dgpg.executable=gpg2 -DperformRelease -Psonatype-oss-release -DskipTests -DstagingRepositoryId=$STAGING_REPOSITORY
source change-scala-versions.sh 2.10
source change-spark-versions.sh 1
mvn clean deploy -Dgpg.executable=gpg2 -DperformRelease -Psonatype-oss-release -DskipTests -DstagingRepositoryId=$STAGING_REPOSITORY

source change-spark-versions.sh 1
source change-scala-versions.sh 2.11
git commit -a -m "Update to version $RELEASE_VERSION"
git tag -a -m "datavec-$RELEASE_VERSION" "datavec-$RELEASE_VERSION"

sed -i "s/<nd4j.version>.*<\/nd4j.version>/<nd4j.version>$SNAPSHOT_VERSION<\/nd4j.version>/" pom.xml
#Spark versions, like <version>xxx_spark_2-SNAPSHOT</version>
SPLIT_VERSION=(${SNAPSHOT_VERSION//-/ })
for f in $(find . -name 'pom.xml' -not -path '*target*'); do
    sed -i "s/version>.*_spark_.*</version>${SPLIT_VERSION[0]}_spark_1-${SPLIT_VERSION[1]}</g" $f
done
mvn versions:set -DallowSnapshots=true -DgenerateBackupPoms=false -DnewVersion=$SNAPSHOT_VERSION
git commit -a -m "Update to version $SNAPSHOT_VERSION"

echo "Successfully performed release of version $RELEASE_VERSION ($SNAPSHOT_VERSION) to repository $STAGING_REPOSITORY"
