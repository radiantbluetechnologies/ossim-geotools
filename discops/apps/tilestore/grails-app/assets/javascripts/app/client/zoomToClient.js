ZoomToClient = (function () {

    var zoomLocationSplit, zoomLat, zoomLon;

    // Suppress Enter key from causing a submit behavior
    $('#zoomToForm').keypress(function(event){
        if (event.keyCode == 10 || event.keyCode == 13)
            event.preventDefault();
    });

    $('#zoomButton').on("click", function () {

        var coordSelect = $('#coordSelect').val();
        // TODO: Disable input from hitting the Enter/Return
        //       key.  We want it to come through the click
        //       event of the #zoomButton
        var coordInput = $('#coordInput').val();

        splitCoords(coordInput);

        console.log('zoomTo Values: ' + 'Lat: ' + zoomLat + ' Lon: ' + zoomLon);

        switch (coordSelect) {
            case 'dd':
                cycleRegExs(coordInput);
                break;
            case 'dms':
                cycleRegExs(coordInput);
                break;
            case 'mgrs':
                cycleRegExs(coordInput);
                break;
            default:
                console.log('No match');
        }

    });

    // TODO: Need to add some validatation to see if the user
    //       enters a valid coordinate and scrub it for spaces in
    //       beginning and end of input.  Also need to account
    //       for there not being a comma in the input.

    //      Possible if...then that checks the content of the string
    //      to see if there is a comma.  If not execute using a "space"
    //      as the split.
    function splitCoords(zoomLocation){
        //console.log('calling splitCoords function');
        if (zoomLocation.toLowerCase().indexOf(",") >= 0){
            //console.log(zoomLocation.toLowerCase().indexOf(","));
            //console.log('A comma was found!');
            zoomLocationSplit = zoomLocation.trim().split(',');
            zoomLat = zoomLocationSplit[0].trim();
            zoomLon = zoomLocationSplit[1].trim();

        }
        else if (zoomLocation.toLowerCase().indexOf(" ") >= 0){
            console.log(zoomLocation);
            console.log(zoomLocation.toLowerCase().indexOf(" "));
            console.log('Space!');
            zoomLocationSplit = zoomLocation.trim().split(/\s+/); // to account for more than one space
            console.log(zoomLocationSplit);
            zoomLat = zoomLocationSplit[0].trim();
            zoomLon = zoomLocationSplit[1].trim();
        }
        else {
            console.log('No comma, or space present.');
            // Error handling...
        }

    }

    var convert = new CoordinateConversion();    

    var ddRegExp = /^\s*(\-?\d{1,2}\.\d*)\s*\°?\s*([NnSs])?\s*\,?\s*(\-?\d{1,3}\.\d*)\s*\°?\s*([WwEe])?\s*$/
    var dmsRegExp = /^(\d{1,2})\s?\°?\s?\:?\s?(\d{1,2})\s?\'?\s?\:?\s?(\d{1,2})(\.\d*)?\s?([NnSs])\s?(\d{1,3})\s?\°?\s?\:?\s?(\d{1,2})\s?\'?\s?\:?\s?(\d{1,2})(\.\d*)?\s?([EeWw])$/
    var mgrsRegExp = /^(\d{1,2})\s?([A-Za-z])\s?([A-Za-z])\s?([A-Za-z])\s?(\d{1,5})\s?(\d{1,5})$/

    function cycleRegExs(coordInput)
    {
        if (coordInput.match(ddRegExp)) {
            console.log('DD Match');

            // ^(\-?\d{1,2}\.\d*)\s?\°?\s?([NnSs])?\s?\,?\s?(\-?\d{1,3}\.\d*)\s?\°?\s?([EeWw])?$

            var lat;
            var lon;
            
            // validate lat
            if (RegExp.$1 <= 90 && RegExp.$1 >= -90) {

                if(RegExp.$2 == "S" || RegExp.$2 == "s") {
                    lat = -RegExp.$1;
                }
                else {
                    lat = RegExp.$1;
                }
            }

            // validate lon
            if (RegExp.$3 <= 180 && RegExp.$3 >= -180) {

                if(RegExp.$4 == "W" || RegExp.$4 == "w") {
                    lon = -RegExp.$3;
                }
                else {
                    lon = RegExp.$3;
                }
            }

            zoomTo(lat, lon);

            $('#coordSelect').selectpicker('val', 'dd');
        }

        else if (coordInput.match(dmsRegExp)) {
            console.log('DMS Match');
            
            // ^(\d{1,2})\s?\°?\s?\:?\s?(\d{1,2})\s?\'?\s?\:?\s?(\d{1,2})(\.\d*)?\s?([NnSs])\s?
            //      (\d{1,3})\s?\°?\s?\:?\s?(\d{1,2})\s?\'?\s?\:?\s?(\d{1,2})(\.\d*)?\s?([EeWw])$

            var latDeg = RegExp.$1;
            var latMin = RegExp.$2;
            var latSec = RegExp.$3 + RegExp.$4;
            var latHem = RegExp.$5;

            var lonDeg = RegExp.$6;
            var lonMin = RegExp.$7;
            var lonSec = RegExp.$8 + RegExp.$9;
            var lonHem = RegExp.$10;

            var lat = convert.dmsToDd(latDeg, latMin, latSec, latHem);
            var lon = convert.dmsToDd(lonDeg, lonMin, lonSec, lonHem);
            

            zoomTo(lat, lon);

            $('#coordSelect').selectpicker('val', 'dms');    
        }
        
        else if (coordInput.match(mgrsRegExp)) {
            console.log('MGRS Match');

            // ^(\d{1,2})\s?([A-Za-z])\s?([A-Za-z])\s?([A-Za-z])\s?(\d{1,5})\s?(\d{1,5})$

            var mgrs = convert.mgrsToDd(RegExp.$1, RegExp.$2, RegExp.$3, RegExp.$4, RegExp.$5, RegExp.$6)

            // strip lat, lon
            if(mgrs.match(ddRegExp)) {
                var lat = RegExp.$1;
                var lon = RegExp.$3;

                zoomTo(lat, lon);

                $('#coordSelect').selectpicker('val', 'mgrs');
            }
       }

       else {
            console.log('No Match')
       }
    }

    function zoomTo(lat, lon) {

        //var duration = 2000;
        //var start = +new Date();
        //var pan = ol.animation.pan({
        //    duration: duration,
        //    source: /** @type {ol.Coordinate} */ (AppClient.mapView.getCenter()),
        //    start: start
        //});
        //var bounce = ol.animation.bounce({
        //    duration: duration,
        //    resolution: 4 * AppClient.mapView.getResolution(),
        //    start: start
        //});
        //
        //AppClient.map.beforeRender(pan, bounce);

        //console.log('In ZoomTo ' + 'Lat:' + parseFloat(lat) + ' ' + ' Lon:' + parseFloat(lon));

        //var pan = ol.animation.pan({
        //    duration: 2000,
        //    easing: ol.easing.elastic,
        //    source: /** @type {ol.Coordinate} */ (AppClient.mapView.getCenter())
        //});
        //AppClient.map.beforeRender(pan);

        AppClient.mapView.setCenter(ol.proj.transform([parseFloat(lon), parseFloat(lat)], 'EPSG:4326', 'EPSG:3857'))
        AppClient.mapView.setZoom(15);

        //console.log('zoomTo done firing...');

    }


// [0-9]{1,2}[:|°][0-9]{1,2}[:|'](?:\b[0-9]+(?:\.[0-9]*)?|\.[0-9]+\b)"?(|\s)[N|n|S|s|E|e|W|w]

    return {

        initialize: function () {
            //console.log('initialize firing in ZoomToClient.js');
        }
    }

})();
