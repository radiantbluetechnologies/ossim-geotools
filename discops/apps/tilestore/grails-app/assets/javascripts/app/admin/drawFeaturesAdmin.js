"use strict";
var AppDrawFeaturesAdmin = (function () {

    var loadParams, outputWkt, formatWkt, drawInteractionFree, drawInteractionRect;
    var $drawRectangle = $('#drawRectangle');
    var $drawPolygon = $('#drawPolygon');
    var $tileLayerSelect = $('#tileLayerSelect');
    var $mapOmarInfo = $('#mapOmarInfo');

    var aoiFeature = new ol.Feature();

    $drawRectangle.on('click', function(){
        addInteraction('Rectangle');
    });

    $drawPolygon.on('click', function(){
        addInteraction('Polygon');
    });

    function addInteraction(value) {

        // Clear the draw/cut interactions if they exist
        if (drawInteractionFree || drawInteractionRect){
            console.log('drawinteractions present...removing existing interactions');
            AppAdmin.mapOmar.removeInteraction(drawInteractionFree);
            AppAdmin.mapOmar.removeInteraction(drawInteractionRect);
        }
        else{
            console.log('drawinteractions NOT present...');
        }

        if (value === 'Polygon') {

            // Create the freehand poly cut tool if it doesn't exist
            if (!drawInteractionFree){
                console.log('!drawInteractionFree');
                drawInteractionFree = new ol.interaction.Draw({
                    source: AppManageLayersAdmin.aoiSource,
                    type: (value)
                });
            }

            AppAdmin.mapOmar.addInteraction(drawInteractionFree);
            $mapOmarInfo.html('Cutting by: Freehand Polygon');
            $mapOmarInfo.show();

            drawInteractionFree.on('drawend', function (evt) {
                aoiFeature = evt.feature;
                console.log(aoiFeature.getGeometry());
                addAoiFeaturePolygon(aoiFeature.getGeometry());
            });

        }
        else if (value === 'Rectangle') {

            // Create the rectangle cut tool if it doesn't exist
            if(!drawInteractionRect){
                console.log('!drawInteractionRect');
                drawInteractionRect = new ol.interaction.DragBox({
                    style: AppManageLayersAdmin.aoiStyle
                });
            }

            drawInteractionRect.on('boxend', function () {
                addAoiFeatureRectangle();
            });

            AppAdmin.mapOmar.addInteraction(drawInteractionRect);
            $mapOmarInfo.html('Cutting by: Rectangle');
            $mapOmarInfo.show();

        }
        // TODO: Circle back to this, as converting from a circle geom to WKT is not posssilbe
        // http://gis.stackexchange.com/questions/144617/using-wkt-writegeometry-for-circle-geometry-in-openlayers
        // and http://stackoverflow.com/questions/26970150/how-to-interactively-draw-a-circle-in-openlayers-3
        //if (value === 'Circle'){
        //
        //}
        //AppAdmin.mapOmar.addInteraction(drawInteractionRect);

        $('#endCuts').html('<i class="fa fa-toggle-on fa-lg"></i>&nbsp;&nbsp;Cutting On')
            .closest('li')
            .removeClass('disabled');

    }

    function addAoiFeaturePolygon(geom) {

        // Check to see if there are any features in the source,
        // and if so we need to remove them before adding a new AOI.
        //console.log(aoiVector.getSource().getFeatures().length);
        if (AppManageLayersAdmin.aoiVector.getSource().getFeatures().length >= 1) {
            AppManageLayersAdmin.aoiVector.getSource().clear();
            console.log(AppManageLayersAdmin.aoiVector.getSource().getFeatures().length);
        }

        formatWkt = new ol.format.WKT();
        outputWkt = formatWkt.writeGeometry(geom);

        console.log(outputWkt);
        console.log($tileLayerSelect.val());

        AppIngestTileAdmin.objIngestImage.aoi = outputWkt;

        AppIngestTileAdmin.getIngestImageObj();

    }

    function addAoiFeatureRectangle(){
        console.log(AppManageLayersAdmin.aoiVector.getSource().getFeatures().length);

        if (AppManageLayersAdmin.aoiVector.getSource().getFeatures().length >= 1) {
            AppManageLayersAdmin.aoiVector.getSource().clear();
            console.log(AppManageLayersAdmin.aoiVector.getSource().getFeatures().length);
        }

        // Pass the 'output' as a WKT polygon
        var output = drawInteractionRect.getGeometry();

        formatWkt = new ol.format.WKT();
        outputWkt = formatWkt.writeGeometry(drawInteractionRect.getGeometry());

        console.log(outputWkt);

        aoiFeature.setGeometry(output);
        AppManageLayersAdmin.aoiVector.getSource().addFeature(aoiFeature);

        AppIngestTileAdmin.objIngestImage.aoi = outputWkt;

        AppIngestTileAdmin.getIngestImageObj();


    }

    // Remove the AOI feature if the user closes the ingest image modal window
    $('#ingestImageModal').on('hidden.bs.modal', function (e) {
        AppManageLayersAdmin.aoiVector.getSource().clear();
    });

    $('#endCuts').on('click', function(){

        console.log('endCuts fired...')
        AppAdmin.mapOmar.removeInteraction(drawInteractionFree);
        AppAdmin.mapOmar.removeInteraction(drawInteractionRect);
        AppManageLayersAdmin.aoiVector.getSource().clear();
        $('#endCuts').html('<i class="fa fa-toggle-off fa-lg"></i>&nbsp;&nbsp;Cutting Off')
            .closest('li')
            .addClass('disabled');
        $mapOmarInfo.html('');
        $mapOmarInfo.hide();
    })

    return {
        initialize: function (initParams) {
            //console.log(initParams);
            loadParams = initParams;
        }
    };

})();


