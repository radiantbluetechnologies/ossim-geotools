package tilestore.database

import geoscript.GeoScript
import geoscript.geom.Bounds
import geoscript.geom.Geometry
import geoscript.geom.Polygon
import grails.converters.JSON
import grails.transaction.Transactional
import groovy.xml.StreamingMarkupBuilder
import joms.geotools.tileapi.TileCachePyramid
import joms.geotools.tileapi.hibernate.TileCacheHibernate
import joms.geotools.tileapi.hibernate.controller.TileCacheServiceDAO
import joms.geotools.tileapi.hibernate.domain.TileCacheLayerInfo
import joms.geotools.web.HttpStatus
import joms.oms.ossimGpt
import org.geotools.factory.Hints
import org.springframework.beans.factory.InitializingBean
import tilestore.job.CreateJobCommand
import tilestore.job.JobStatus

import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.LinkedBlockingQueue

@Transactional
class LayerManagerService implements InitializingBean
{

   def grailsApplication
   def jobService
   TileCacheHibernate hibernate
   TileCacheServiceDAO daoTileCacheService
   def dataSourceProps
   LinkedBlockingQueue getMapBlockingQueue
   ConcurrentHashMap layerCache = new ConcurrentHashMap()

   def layerReaderCache = [:]
   static def id = 0

   void afterPropertiesSet() throws Exception
   {
      Hints.putSystemDefault( Hints.FORCE_LONGITUDE_FIRST_AXIS_ORDER, Boolean.TRUE )

      if ( ! grailsApplication.config.tilestore.disableAccumulo  )
      {
         hibernate = new TileCacheHibernate()
         dataSourceProps = grailsApplication.config.dataSource.toProperties()
         hibernate.initialize( [
                 dbCreate: dataSourceProps.dbCreate,
                 driverClassName: dataSourceProps.driverClassName,
                 username: dataSourceProps.username,
                 password: dataSourceProps.password,
                 url: dataSourceProps.url,
                 accumuloInstanceName: grailsApplication.config.accumulo.instance,
                 accumuloPassword: grailsApplication.config.accumulo.password,
                 accumuloUsername: grailsApplication.config.accumulo.username,
                 accumuloZooServers: grailsApplication.config.accumulo.zooServers
         ] )
         daoTileCacheService = hibernate.applicationContext.getBean( "tileCacheServiceDAO" );
      }

      getMapBlockingQueue = new LinkedBlockingQueue( grailsApplication.config.tilestore.maxTileConnections ?: 20 )
      ( 0..<10 ).each { getMapBlockingQueue.put( it ) }

      // println "DATA SOURCE ===== ${dataSource}"
      // println "DATA SOURCE UNPROXIED ===== ${dataSourceUnproxied}"
   }
   /**
    *
    * We will create the Layer table and the table for caching tiles in postgres and
    * will create the tile store in accumulo
    *
    * When a layer is created we add it's meta information that describes the projection and bounds
    * and layer ranges into a layer info table.  We next create a tile table that holds
    * modification dates and tile bounds and then we create a table in accumulo for
    * storing the tile definitions
    *
    * @param params
    * @return
    */
   def createOrUpdate(CreateLayerCommand cmd)
   {
      def result = [status: HttpStatus.OK,
                    data: null,
                    message: ""]

      result.data = daoTileCacheService.getLayerInfoByName( cmd.name )
      if ( !result.data )
      {
         result.data = daoTileCacheService.createOrUpdateLayer(
                 new TileCacheLayerInfo( name: cmd.name,
                         bounds: cmd.clip,
                         epsgCode: cmd.epsgCode,
                         tileHeight: cmd.tileHeight,
                         tileWidth: cmd.tileWidth,
                         minLevel: cmd.minLevel,
                         maxLevel: cmd.maxLevel )
         )
      }
      else
      {
         if ( cmd.bbox != null )
         {
            result.data.bounds = cmd.clip
         }
         if ( cmd.tileWidth != null )
         {
            result.data.tileWidth = cmd.tileWidth
         }
         if ( cmd.tileHeight != null )
         {
            result.data.tileHeight = cmd.tileHeight
         }
         if ( cmd.epsgCode != null )
         {
            result.data.epsgCode = cmd.epsgCode
         }
         if ( cmd.minLevel != null )
         {
            result.data.minLevel = cmd.minLevel
         }
         if ( cmd.maxLevel != null )
         {
            result.data.maxLevel = cmd.maxLevel
         }

         result.data = daoTileCacheService.createOrUpdateLayer( result.data )
      }
      if ( !result.data )
      {
         result.status = HttpStatus.NOT_FOUND
         result.message = "Unable to update or create layer with name ${cmd.name}"
      }
      result
   }

   def create(CreateLayerCommand cmd)
   {
      def result = [data: null,
                    status: HttpStatus.OK,
                    message: ""]
      def layer = daoTileCacheService.getLayerInfoByName( cmd.name )
      if ( !layer )
      {
         TileCacheLayerInfo info = daoTileCacheService.createOrUpdateLayer(
                 new TileCacheLayerInfo( name: cmd.name,
                         bounds: cmd.clip,
                         epsgCode: cmd.epsgCode,
                         tileHeight: cmd.tileHeight,
                         tileWidth: cmd.tileWidth,
                         minLevel: cmd.minLevel,
                         maxLevel: cmd.maxLevel )
         )

         if ( info )
         {
            Bounds b = new Polygon( info.bounds ).bounds

            result.data = [name: info.name,
                           bbox: "${b.minX},${b.minY},${b.maxX},${b.maxY}", //new Projection( params.epsgCode ).bounds.polygon.g,
                           epsgCode: info.epsgCode,
                           tileHeight: info.tileHeight,
                           tileWidth: info.tileWidth,
                           minLevel: info.minLevel,
                           maxLevel: info.maxLevel]
         }
         else
         {
            result.status = HttpStatus.BAD_REQUEST
            result.message = "Unable to create layer name ${cmd.name}"
         }
         if ( !result.data )
         {
            result.status = HttpStatus.BAD_REQUEST
            result.message = "Unable create layer with name ${cmd.name}"
         }
      }
      else
      {
         result.status = HttpStatus.BAD_REQUEST
         result.message = "Unable to create a new layer.  Layer ${cmd.name} already exists."
      }

      result
   }

   def show(String name)
   {
      def result = [status: HttpStatus.OK, message: ""]
      TileCacheLayerInfo info = daoTileCacheService.getLayerInfoByName( name )
      if ( info )
      {
         Bounds b = new Polygon( info.bounds ).bounds

         result.data = [name: info.name,
                        bbox: "${b.minX},${b.minY},${b.maxX},${b.maxY}", //new Projection( params.epsgCode ).bounds.polygon.g,
                        epsgCode: info.epsgCode,
                        tileHeight: info.tileHeight,
                        tileWidth: info.tileWidth,
                        minLevel: info.minLevel,
                        maxLevel: info.maxLevel]
      }
      else
      {
         result.status = HttpStatus.NOT_FOUND
         result.message = "Unable to find layer name ${name}"
      }

      result
   }

   def delete(String name)
   {
      def result = [status: HttpStatus.OK,
                    message: ""]
      TileCacheLayerInfo layerInfo = daoTileCacheService.getLayerInfoByName( name )
      if ( layerInfo )
      {
         daoTileCacheService.deleteLayer( name )
         layerInfo = daoTileCacheService.getLayerInfoByName( name )

         result.message = "Layer ${name} removed"
      }
      else
      {
         result.status = HttpStatus.BAD_REQUEST
         result.message = "Layer name '${name}' does not exist for deleting"
      }

      result
   }

   def list()
   {
      def result = [data: [total: 0, rows: []],
                    status: HttpStatus.OK,
                    message: ""];
      daoTileCacheService.listAllLayers().each { info ->
         Bounds b
         if ( info.bounds )
         {
            b = new Polygon( info.bounds ).bounds
         }

         def boundsStr = ""
         if ( b )
         {
            boundsStr = "${b.minX},${b.minY},${b.maxX},${b.maxY}"
         }
         def tempInfoMap = [id: info.id,
                            name: info.name,
                            bbox: boundsStr,
                            epsgCode: info.epsgCode,
                            tileHeight: info.tileHeight,
                            tileWidth: info.tileWidth,
                            minLevel: info.minLevel,
                            maxLevel: info.maxLevel]

         result.data.rows << tempInfoMap
      }

      result
   }

   List<TileCacheLayerInfo> getTileCacheLayers() throws Exception
   {
      daoTileCacheService.listAllLayers()
   }


   def renameLayer(String oldName, String newName)
   {
      def result = [status: HttpStatus.OK, message: ""]
      try
      {
         daoTileCacheService.renameLayer( oldName, newName )
      }
      catch ( e )
      {
         result.status = HttpStatus.BAD_REQUEST
         result.message = "${e}"
      }

      result
   }

   def tileAccess(def params)
   {
      def result = ""

      if ( params.layer )
      {

         TileCacheLayerInfo layerInfo = daoTileCacheService.getLayerInfoByName( params.layer )

         if ( layerInfo )
         {
            def masterTableName = 'tile_cache_layer_info'
            def layerName = layerInfo.name
            def tileAccessClass = grailsApplication.config.accumulo.tileAccessClass
            //   def tileAccessClass = 'tilecache.AccumuloTileAccess'

            def x = {
               mkp.xmlDeclaration()
               config( version: '1.0' ) {
                  coverageName( name: layerName )
                  coordsys( name: 'EPSG:4326' )
                  scaleop( interpolation: 1 )
                  axisOrder( ignore: false )
                  spatialExtension( name: 'custom' )
                  jdbcAccessClassName( name: tileAccessClass )
                  connect {
                     dstype( value: 'DBCP' )
                     username( value: "${dataSourceProps.username}" )
                     password( value: "${dataSourceProps.password}" )
                     jdbcUrl( value: "${dataSourceProps.url}" )
                     driverClassName( value: "${dataSourceProps.driverClassName}" )
                     maxActive( value: 10 )
                     maxIdle( value: 0 )

                     accumuloPassword( value: "${grailsApplication.config.accumulo.password}" )
                     accumuloUsername( value: "${grailsApplication.config.accumulo.username}" )
                     accumuloInstanceName( value: "${grailsApplication.config.accumulo.instance}" )
                     accumuloZooServers( value: "${grailsApplication.config.accumulo.zooServers}" )
                  }
                  mapping {
                     masterTable( name: masterTableName ) {
                        coverageNameAttribute( name: 'name' )
                        tileTableNameAtribute( name: 'tile_store_table' )
                        spatialTableNameAtribute( name: 'tile_store_table' )
                     }
                     tileTable {
                        keyAttributeName( name: 'hash_id' )
                     }
                     spatialTable {
                        keyAttributeName( name: 'hash_id' )
                        geomAttributeName( name: 'bounds' )
                     }

                  }
               }
            }
            def builder = new StreamingMarkupBuilder().bind( x )

            result = builder.toString()
         }
      }
      //println result

      result
   }

   def getActualBounds(def params)
   {
      def constraints = [:]

      if ( params.aoi )
      {
         constraints.intersects = "${params.aoi}"
      }

      daoTileCacheService.getActualLayerBounds( params?.name, constraints )
   }

   def createTileLayers(String[] layerNames)
   {
      def layers = []
      //def gridFormat = new ImageMosaicJDBCFormat()
      //GridFormatFinder.findFormat(new URL("http://localhost:8080/tilestore/accumuloProxy/tileAccess?layer=BMNG"))
      layerNames.each { layer ->
         //   def gridReader = gridFormat.getReader( new URL( "${tileAccessUrl}?layer=${layer}" ) )
         //   def mosaic = new GridReaderLayer( gridReader, new RasterSymbolizer().gtStyle )

         def l = layerCache.get( layer )
         if ( !l )
         {
            l = daoTileCacheService.newGeoscriptTileLayer( layer )
            layerCache.put( layer, l )
         }
         // println l
         if ( l )
         {
            layers << l
         }
      }
      layers
   }

   def createSession()
   {
      getMapBlockingQueue.take()
   }

   def deleteSession(def session)
   {
      getMapBlockingQueue.put( session )
   }

   def getFirstTileMeta(GetFirstTileCommand cmd)
   {
      def result = [status : HttpStatus.OK,
                    message: "",
                    data   : [] ]

      if(cmd.layer)
      {
         def layerInfo = daoTileCacheService.getLayerInfoByName(cmd.layer)
         if(layerInfo)
         {
            def tileList = daoTileCacheService.getTilesMetaWithinConstraints(layerInfo, [offset:0, maxRows:1,orderBy:"Z+D"])
            HashMap tempResult = tileList[0]
            if(tempResult.bounds)
            {
               Geometry g = GeoScript.wrap(tempResult.bounds)
               Bounds b = g.bounds
               tempResult.bounds = tempResult.bounds.toString()

               tempResult.centerX =(b.minX+b.maxX)*0.5
               tempResult.centerY =(b.minY+b.maxY)*0.5
               tempResult.minx = b.minX
               tempResult.miny = b.minY
               tempResult.maxx = b.maxX
               tempResult.maxy = b.maxY
               tempResult.epsg = layerInfo.epsgCode
            }

            result.data = tempResult
         }
      }

      result
   }
   def getClampedBounds(GetClampedBoundsCommand cmd)
   {
      def result = [status : HttpStatus.OK,
                    message: "",
                    data   : []
      ]
      def gpt = new ossimGpt()

      TileCachePyramid pyramid = daoTileCacheService.newPyramidGivenLayerName(cmd.layerName)
      String resUnits = cmd.resUnits?.toLowerCase()
      if(pyramid.proj.epsg == 4326)
      {
         // make sure the units are geographic
         if(resUnits&&(resUnits != "degrees"))
         {
            cmd.res = cmd.res*(1.0/gpt.metersPerDegree().y)
         }
      }
      else
      {
         // make sure the units are meters
         if(resUnits&&(resUnits!= "meters"))
         {
            cmd.res = cmd.res*(gpt.metersPerDegree().y)
         }
      }

      result.data = pyramid.clampLevels(cmd.res, cmd.resLevels)

      gpt.delete()
      gpt = null

      result
   }
   def ingest(IngestCommand cmd)
   {
      def result = [status : HttpStatus.OK,
                    message: "",
                    data   : []
      ]
      if(cmd.layer.name)
      {

         TileCacheLayerInfo layerInfo = daoTileCacheService.getLayerInfoByName(cmd.layer.name)
         if(layerInfo)
         {

            cmd.layer.epsg       = layerInfo.epsgCode
            cmd.layer.tileWidth  = layerInfo.tileWidth
            cmd.layer.tileHeight = layerInfo.tileHeight
         }
         else
         {
            result.status = HttpStatus.NOT_FOUND
            result.message = "Layer name ${cmd.input.name}"
            return result
         }

      }
      else
      {
         result.status = HttpStatus.NOT_FOUND
         result.message = "Layer name can't be empty."

         return result
      }
      String jobId = UUID.randomUUID().toString()
      HashMap ingestCommand = cmd.toMap();
      ingestCommand.jobName = ingestCommand.jobName?:"Ingest"
      ingestCommand.jobId = jobId
      ingestCommand.type = "TileServerIngestMessage"

      CreateJobCommand jobCommand = new CreateJobCommand(
              jobId: jobId,
              type: "TileServerIngestMessage",
              jobDir: "",
              name: cmd.jobName,
              username: "anonymous",
              status: JobStatus.READY.toString(),
              statusMessage: "",
              message: (ingestCommand as JSON).toString(),
              jobCallback: null,
              percentComplete: 0.0,
      )

      result = jobService.create(jobCommand)

      result
   }

}
