package tilestore.wfs.formats

import geoscript.filter.Filter
import geoscript.layer.Layer
import geoscript.layer.io.GeoJSONWriter
import grails.converters.JSON
import org.joda.time.DateTime
import org.joda.time.DateTimeZone

/**
 * Created with IntelliJ IDEA.
 * User: sbortman
 * Date: 2/25/13
 * Time: 9:21 AM
 * To change this template use File | Settings | File Templates.
 */
class GeoJsonResultFormat implements ResultFormat
{
  def name = "GEOJSON"
  def contentType = 'application/json'

  def getFeature(def wfsRequest, def workspace)
  {

//    println wfsRequest

    def results
    def layerName = wfsRequest?.typeName?.split(':')[-1]
    def layer = workspace[layerName]
    def filter = [
        filter: wfsRequest?.filter ?: Filter.PASS,
        //sort: ""// [["<COLUMN NAME>","ASC|DESC"]]
    ]
    def filterParams = [
        filter: wfsRequest?.filter ?: Filter.PASS,
        max: wfsRequest.maxFeatures ?: -1,
        start: wfsRequest?.startIndex ?: -1,
        //sort: [["<COLUMN NAME>","ASC|DESC"]]
    ]
    if ( wfsRequest.sortBy )
    {

      // filterParams.sort =null//[["TITLE".toUpperCase(),"DESC"]]
      filterParams.sort = wfsRequest.convertSortByToArray();//wfsRequest.sortBy.substring()//JSON.parse( wfsRequest.sort );

      //println filterParams
    }
    try
    {
      filter = new Filter( filterParams.filter )
    }
    catch ( e )
    {
      e.printStackTrace()
    }

    if ( wfsRequest.resultType?.toLowerCase() == "hits" )
    {
      def count = layer.count( filter );
      def timestamp = new DateTime( DateTimeZone.UTC );
      results = "${[numberOfFeatures: count, timestamp: timestamp?.toString()] as JSON}"
    }
    else
    {
      def writer = new GeoJSONWriter()
      def cursor = layer.getCursor( filterParams );
      def newLayer = new Layer( cursor.col )

      results = writer.write( newLayer )
      cursor?.close()
    }
    workspace?.close()

    return [results, contentType]
  }

}
