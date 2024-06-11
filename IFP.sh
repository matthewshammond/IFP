#!/usr/bin/env bash

# check for logs directory and create if does not exist
[ ! -d "$HOME"/logs ] && mkdir "$HOME"/logs

# stderr & stdout logging
# exec 3>&1 4>&2
# trap 'exec 2>&4 1>&3' 0 1 2 3
# exec 1>$HOME/logs/IFP.log 2>&1
exec 1> >(tee "$HOME"/logs/IFP.log) 2>&1

# Ask for the Navdata publication date to sort
echo 'Navdata Publication Date (MM/DD/YYYY):'
read -r navdata

# Airport Directory
Dir=~/Documents/Aviation/Instruments/IFP\ Information\ Gateway

# Airports
airports=(
	18A
	1A3
	2J3
	2J5
	3J7
	52A
	6A2
	6A3
	6J4
	D73
	ABY
	ACJ
	AGS
	AHN
	AIK
	AJR
	AMG
	AQX
	ATL
	BGE
	BQK
	BXG
	CAE
	CCO
	CHS
	CKF
	CNI
	CQW
	CSG
	CTJ
	CUB
	CVC
	CWV
	CZL
	DBN
	DNL
	DNN
	DQH
	DZJ
	EBA
	EZM
	FFC
	FTY
	FZG
	GRD
	GVL
	HQU
	IIY
	JCA
	JYL
	JZP
	LGC
	LZU
	MAC
	MCN
	MGR
	MHP
	MLJ
	OKZ
	PDK
	PUJ
	PXE
	RHP
	RMG
	RVJ
	RYY
	SAV
	SBO
	TBR
	TMA
	VDI
	VLD
	VPC
	WDR
)

# Change to Airport Directory
cd "${Dir}" || exit

# Create results.csv file if does not exist
[ ! -f results.csv ] && touch results.csv || echo "" >results.csv

# Loop through all airports in IFP Information Gateway
for i in "${airports[@]}"; do
	curl -o "${i}".csv "https://www.faa.gov/air_traffic/flight_info/aeronav/procedures/application/index.cfm?event=procedure.exportResults&tab=productionPlan&nasrId=${i}"
	(grep -q html "${i}.csv") && rm -rf "${i}".csv
done

# Loop through all Airport files and put in results.csv
for file in "${airports[@]}"; do
	sed -i '' 's/ /\n/g' "${file}".csv 2>/dev/null
	sed -i '' 1d "${file}".csv 2>/dev/null
	awk '{print$0}' "${file}".csv >>results.csv 2>/dev/null
	rm -rf "${file}".csv
done

# Sort results for publication date and add header to file
header="\"Procedure Name\",\"Airport ID\",\"ICAO ID\",\"Airport Name\",\"City\",\"State\",\"Scheduled Pub Date\",\"Status\",\"Actual Pub Date\""
sed -i '' "/${navdata//\//\\/}/!d" results.csv
sed -i '' "1s/^/$header\n/g" results.csv

echo "NavData update completed at $(date +%Y/%m/%d-%H:%M:%S)"
ntfy -t "$(hostname)" send "NavData update completed at $(date +%Y/%m/%d-%H:%M:%S)"
open "${Dir}"
