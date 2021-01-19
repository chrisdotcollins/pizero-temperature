#!/bin/bash
 mkdir /dev/shm/pizero/
 cd /dev/shm/pizero/

 if [ -d .git ]; then
  echo .git;
 else
  git clone https://github.com/chrisdotcollins/pizero-cron.git
 fi;

 TEMP_IS=$( ./gettemp.sh )
 DATE_EP=$( date +%s)
 DATE_IS=$( date +%Y-%m-%dT%H:%M:%S )

 git pull pizero-crontemp.log
##
# Use this version to supplement data
 cat /dev/shm/pizero/pizero-crontemp.log | awk -v DATE_EP=${DATE_EP} ' $2 > (DATE_EP - 86400) ' > tmp && mv tmp /dev/shm/pizero/pizero-crontemp.log
 echo $DATE_IS $DATE_EP $TEMP_IS >> /dev/shm/pizero/pizero-crontemp.log

##
# Comment out to reset the log
# echo $DATE_IS $DATE_EP $TEMP_IS > /dev/shm/pizero/pizero-crontemp.log

CHART=$( cat /dev/shm/pizero/pizero-crontemp.log | tail -n 288 | awk -v q="'" '{ print "["q$1q","$3"]," }' )

cat << EOF > charts.html
<html>
  <head>
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <script type="text/javascript">
      google.charts.load('current', {'packages':['corechart']});
      google.charts.setOnLoadCallback(draw1Visualization);

//######
      function draw1Visualization() {
		// Some raw data (not necessarily accurate)
	var data = google.visualization.arrayToDataTable([
		['Time', 'Temp'],
		$CHART
		]);
        var options = {
          title : 'PiZero Temp Log',
          vAxis: {title: 'Degrees',minValue:7,viewWindow:{ min: 7 }},
          hAxis: {title: 'Timestamp'},
          seriesType: 'bars',
          series: {1: {type: 'line'}}
        };

        var chart = new google.visualization.ComboChart(document.getElementById('chart_div1'));
        chart.draw(data, options);
	}
//######
    </script>
  </head>
  <body>
    <h1>$DATE_IS</h1>

    <div id="chart_div1" style="width: 900px; height: 500px;"></div>
  </body>
</html>
EOF


git add /dev/shm/pizero/pizero-crontemp.log
git add /dev/shm/pizero/charts.html
git commit -m "Updated pizero-crontemp.log"
git push


