package tilecache

/**
 * Created by sbortman on 2/12/15.
 */
trait CaseInsensitiveBind
{
  static def fixParamNames(def params)
  {
    //println params

    def names = ( getMetaClass()?.properties*.name ).sort() - ['class', 'constraints', 'errors']

    def newParams = params.inject( [:] ) { a, b ->
      def propName = names.find { it.equalsIgnoreCase( b.key ) && b.value != null }
      if ( propName )
      {
        //println "${propName}=${b.value}"
        a[propName] = b.value
      }
      else
      {
        a[b.key] = b.value
      }
      a
    }

    params.clear()
    params.putAll( newParams )
  }
}