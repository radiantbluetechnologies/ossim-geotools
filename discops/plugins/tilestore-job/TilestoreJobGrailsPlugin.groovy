import tilestore.job.RabbitMQProducer

class TilestoreJobGrailsPlugin {
    // the plugin version
    def version = "0.1"
    // the version or versions of Grails the plugin is designed for
    def grailsVersion = "2.5 > *"
    // resources that are excluded from plugin packaging
    def pluginExcludes = [
        "grails-app/views/error.gsp"
    ]

    // TODO Fill in these fields
    def title = "Tilestore Job Plugin" // Headline display name of the plugin
    def author = "Your name"
    def authorEmail = ""
    def description = '''\
Brief summary/description of the plugin.
'''

    // URL to the plugin's documentation
    def documentation = "http://grails.org/plugin/tilestore-job"

    // Extra (optional) plugin metadata

    // License: one of 'APACHE', 'GPL2', 'GPL3'
//    def license = "APACHE"

    // Details of company behind the plugin (if there is one)
//    def organization = [ name: "My Company", url: "http://www.my-company.com/" ]

    // Any additional developers beyond the author specified above.
//    def developers = [ [ name: "Joe Bloggs", email: "joe@bloggs.net" ]]

    // Location of the plugin's issue tracker.
//    def issueManagement = [ system: "JIRA", url: "http://jira.grails.org/browse/GPMYPLUGIN" ]

    // Online location of the plugin's browseable source code.
//    def scm = [ url: "http://svn.codehaus.org/grails-plugins/" ]

    def doWithWebDescriptor = { xml ->
        // TODO Implement additions to web.xml (optional), this event occurs before
    }

    def doWithSpring = {
       def grailsApplication = parentCtx?.getBean("grailsApplication")

       if(grailsApplication)
       {
          rabbitProducer(RabbitMQProducer){ bean ->
             bean.autowire      = 'rabbitProducer'
             bean.initMethod    = 'init'
             bean.destroyMethod = 'destroy'
             host            = grailsApplication.config?.rabbitmq?.connection?.host?:""
             port            = grailsApplication.config?.rabbitmq?.connection?.port?:5672
             username        = grailsApplication.config?.rabbitmq?.connection?.username?:""
             password        = grailsApplication.config?.rabbitmq?.connection?.password?:""
             ingest          = grailsApplication.config?.rabbitmq?.ingest?:null
             product          = grailsApplication.config?.rabbitmq?.product?:null
          }
       }
    }

    def doWithDynamicMethods = { ctx ->
        // TODO Implement registering dynamic methods to classes (optional)
    }

    def doWithApplicationContext = { ctx ->
   /*    def grailsApplication = ctx.grailsApplication

        // TODO Implement post initialization spring config (optional)
       def beanNames = ["rabbitProducer"]
       def beans = beans {
          rabbitProducer(RabbitMQProducer){ bean ->
             bean.autowire      = 'rabbitProducer'
             bean.initMethod    = 'init'
             bean.destroyMethod = 'destroy'
             host            = grailsApplication.config?.rabbitmq?.connection?.host?:""
             port            = grailsApplication.config?.rabbitmq?.connection?.port?:5672
             username        = grailsApplication.config?.rabbitmq?.connection?.username?:""
             password        = grailsApplication.config?.rabbitmq?.connection?.password?:""
          }
       }
       beanNames.each { beanName ->
          println "REGISTER BEAN === ${beanName}"
          ctx.registerBeanDefinition( beanName,
                  beans.getBeanDefinition( beanName ) )
       }
     */
    }

    def onChange = { event ->
        // TODO Implement code that is executed when any artefact that this plugin is
        // watching is modified and reloaded. The event contains: event.source,
        // event.application, event.manager, event.ctx, and event.plugin.
    }

    def onConfigChange = { event ->
        // TODO Implement code that is executed when the project configuration changes.
        // The event is the same as for 'onChange'.
    }

    def onShutdown = { event ->
        // TODO Implement code that is executed when the application shuts down (optional)
    }
}
