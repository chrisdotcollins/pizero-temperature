#!/bin/bash
 mkdir /dev/shm/pizero/
 cd /dev/shm/pizero/

 if [ -d pizero-cron/.git ]; then
  echo .git;
 else
  git clone https://github.com/chrisdotcollins/pizero-cron.git
 fi;

 cd pizero-cron

 TEMP_IS=$( ./gettemp.sh )
 DATE_EP=$( date +%s)
 DATE_IS=$( date +%Y-%m-%dT%H:%M:%S )

 git pull pizero-crontemp.log
##
# Use this version to supplement data
 cat /dev/shm/pizero/pizero-cron/pizero-crontemp.log | awk -v DATE_EP=${DATE_EP} ' $2 > (DATE_EP - 86400) ' > tmp && mv tmp /dev/shm/pizero/pizero-cron/pizero-crontemp.log
 echo $DATE_IS $DATE_EP $TEMP_IS >> /dev/shm/pizero/pizero-cron/pizero-crontemp.log

##
# Comment out to reset the log
# echo $DATE_IS $DATE_EP $TEMP_IS > /dev/shm/pizero/pizero-crontemp.log

CHART=$( cat /dev/shm/pizero/pizero-cron/pizero-crontemp.log | tail -n 288 | awk -v q="'" '{ print "["q$1q","$3"]," }' )

cat << EOF > charts.html
<html>
  <head>
    <title>Pizero Temperature real-time plots</title>
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
          title : 'PiZero Temp Log $DATE_IS',
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
    <script type="text/javascript" src="vendor/smoothie.js"></script>
    <script type="text/javascript" src="vendor/reconnecting-websocket.min.js"></script>
    <script type="text/javascript">

      var readings = new TimeSeries();

      function createTimeline() {
        var chart = new SmoothieChart({
          millisPerPixel: 1000,
          interpolation:'bezier',
       grid:{millisPerLine:60000,verticalSections:15,fillStyle:'#ffffff'},
       tooltip:true,
       timestampFormatter:SmoothieChart.timeFormatter,
          minValue:0.0,
          maxValue:30.0
        });

        chart.addTimeSeries(readings, { 
            strokeStyle: '#006eff',
            fillStyle: 'rgba(122,122,122,0.30)',
            lineWidth: 3 });

        chart.streamTo(document.getElementById("chart"), 500);
      }

      var ws = new ReconnectingWebSocket('ws://192.168.1.26:8080/');
      ws.onopen = function() {
        document.body.style.backgroundColor = '#fff';
      };
      ws.onclose = function() {
        document.body.style.backgroundColor = null;
      };
      ws.onmessage = function(event) {
        var data = event.data.split(",");
        var timestamp = parseFloat(data[0]) * 1000;  // expects ms
        var value = parseFloat(data[1]);
        readings.append(timestamp, value);
        document.getElementById("temperature").innerHTML = value;
      };

    var myVar = setInterval(myTimer, 1000);

    function myTimer() {
     var d = new Date();
     var t = 'PiZero Temperature Sensor '+d.toLocaleTimeString();
     document.getElementById("demo2").innerHTML = t;
    }

    </script>
  </head>
  <body onload="createTimeline()">
    <h2 id="demo2"></h2>
    <h2 id="temperature"></h2>
    <canvas id="chart" width=800 height="400"></canvas>
    <div id="chart_div1" style="width: 800px; height: 400px;"></div>

  </body>
</html>
EOF

git remote set-url origin git@github.com:chrisdotcollins/pizero-cron.git
cp charts.html static/index.html
git add /dev/shm/pizero/pizero-cron/pizero-crontemp.log
git add /dev/shm/pizero/pizero-cron/charts.html
git commit -m "Updated pizero-crontemp.log"
git push


