#!/bin/bash



MODULE_PATH="$1"
if [ -z "$MODULE_PATH" ]; then
    echo "Usage: $0 <module_path>"
    exit 1
fi

cd /workspace/target-project || exit 1

echo "testing Step 1"

mvn clean install -pl "$MODULE_PATH" -am -U \
  -Dmaven.test.skip=true -Ddependency-check.skip=true -Dgpg.skip=true -DfailIfNoTests=false \
  -Dskip.installnodenpm -Dskip.npm -Dskip.yarn -Dlicense.skip -Dcheckstyle.skip -Drat.skip \
  -Denforcer.skip -Danimal.sniffer.skip -Dmaven.javadoc.skip -Dfindbugs.skip -Dwarbucks.skip \
  -Dmodernizer.skip -Dimpsort.skip -Dmdep.analyze.skip -Dpgpverify.skip -Dxml.skip \
  -Dcobertura.skip=true -Dfindbugs.skip=true -Dstyle.color=never \
  -Dexec.skip=true \
  -DtestFailureIgnore=true



