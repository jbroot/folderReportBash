#!/bin/bash
#Jarren Briscoe 
#Outputs number of directories, files, symbolic links, files older than 365 days, files above 500,000 bytes, graphics files, temporary files, and executable files.
#Also outputs execution time and the total file size of the given directory


SECONDS=0
#if no directory then exit 1
if [ $# -eq 0 ]
then
        echo "Usage: No directory specified"
        exit 1
fi
USINGDIRECTORY=$1
if [ ! -e $USINGDIRECTORY ]
then
        echo "Usage: No such directory exists"
        exit 1
fi

#display name, hostname, date
echo "SearchReport $HOSTNAME $USINGDIRECTORY $(date)"

#initialize variables to 0
numDir=0
numFiles=0
numSym=0
numOld=0
#larger than 500000b
numLarge=0
numGraphic=0
numTmp=0
numExe=0
totalSize=0
fileSize=0

#size permissions dateModifiedInSeconds filename
files=$(find . -type f -printf "%s\t%M\t%T@\t%f\n")

#find number of files
numFiles=$(echo "$files" | wc -l)

#files older than 365 days
oldDate=$(date -d "-365 days" +%s)
#2nd cut to remove seconds fraction
for iDate in $(echo "$files" | cut -f3 -d$'\t' | cut -f1 -d'.')
do
	[ "$oldDate" -ge "$iDate" ] && numOld=$(($numOld+1))
done

#num directories
numDir=$(find "$USINGDIRECTORY" -type d -not -path "$USINGDIRECTORY" | wc -l)

#executables
numExe=$(echo "$files" | cut -f2 -d$'\t' | grep -c "...x......")

#find temporary files with .o suffix
numTmp=$(echo "$files" | grep -c '.o$')

#find graphics files
#jpeg?
numGraph=$(echo "$files" | grep -e '\.jpg$\|\.gif$\|\.bmp$' | wc -l)

#symbolic links
numSym=$(find "$USINGDIRECTORY" -type l | wc -l)

#large files
for iSize in $(echo "$files" | cut -f1 -d$'\t')
do
	#if bigger than 500000 bytes then increase numLarge
	[ "$iSize" -gt 500000 ] && numLarge=$(($numLarge+1))
	#increase total
	totalSize=$(($totalSize + $iSize))
done



#create report
printf "Execution time %'d\n" $SECONDS
printf "Directories %'d\n" $numDir
printf "Files %'d\n" $numFiles
printf "Sym links %'d\n" $numSym
printf "Old files %'d\n" $numOld
printf "Large files %'d\n" $numLarge
printf "Graphics files %'d\n" $numGraph
printf "Temporary files %'d\n" $numTmp
printf "Executable files %'d\n" $numExe
printf "Total file size %'d\n" $totalSize

exit 0
