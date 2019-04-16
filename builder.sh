#!/bin/bash

# Pre-Condition: 
# NOTHING

# Attention:
# *.zip will be deleted

# Procedure:
# 1. put all *.zip into the src/ folder
# 2. put the external .jar into lib/ folder
# 3. run './builder.sh' 
# 4. the jar-files has been generated in the 'out' folder of the corresponding directory, enjoy!

# file-tree is as follows:
# dir
#  ├──src
#  ├──lib
#  └──builder.sh

cd src/
# 1. unzip and copy lib/ to src/
echo unzip start...

ls *.zip > temp.txt
sed 's/.zip//g' temp.txt > names.txt # sed 's/src/dst/'
names=`cat names.txt`   # attention

# echo $names
for name in ${names[@]}
do
    mkdir $name
    unzip $name.zip -d $name
    cp -a ../lib $name
done

rm *.txt
rm *.zip
echo unzip successfully...


# 2. compile to class
echo complie start...

prefix="javac -encoding utf-8 -d out/ @srcpath.txt "
lib="-classpath /C/Users/94831/Desktop/CourseCenter/OO/testShell/lib/elevator-input-hw3-1.4-jar-with-dependencies.jar:/C/Users/94831/Desktop/CourseCenter/OO/testShell/lib/timable-output-1.1-raw-jar-with-dependencies.jar "
command=${prefix}${lib}

dirs=`ls`
echo $dirs

for dir in ${dirs[@]}
do
    # echo $dir
    cd $dir
    mkdir out
    find -name "*.java" > srcpath.txt
    $command
    # rm srcpath.txt
    cd ..
done

echo compile successfully...


# 3. pack to jar
echo packing to jar...

for dir in ${dirs[@]}
do
    echo $dir
    cd $dir
    # write config information to MANIFEST.mf
    echo -n 'Main-Class: ' > MANIFEST.mf
    grep -l "public static void main" . -r | sed s/\\.\\///g | sed s/src\\///g | sed s/\\.java//g | sed s/\\//./g >> MANIFEST.mf
    sed '2, $d' MANIFEST.mf | tee MANIFEST.mf
    echo 'Class-Path: ../lib/elevator-input-hw3-1.4-jar-with-dependencies.jar ../lib/timable-output-1.1-raw-jar-with-dependencies.jar' >> MANIFEST.mf
    echo >> MANIFEST.mf
    mv MANIFEST.mf out

    cd out
    find -name "*.class" > classpath.txt
    jar cvfm $dir.jar MANIFEST.mf @classpath.txt
    cd ..   # from out
    cd ..   # from player_dir
done

echo pack successfully...

