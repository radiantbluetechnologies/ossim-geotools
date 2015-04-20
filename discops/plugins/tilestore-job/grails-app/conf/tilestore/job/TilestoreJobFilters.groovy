package tilestore.job

class TilestoreJobFilters {

   def filters = {
      ingest(controller:"job", action:"ingest"){
         before = {
            new IngestCommand().fixParamNames( params )
         }
         after = { Map model ->

         }
         afterView = { Exception e ->

         }
      }
      removeJob(controller:"job", action:"remove"){
         before = {
            new RemoveJobCommand().fixParamNames( params )
         }
      }
      getJob(controller:"job", action:"getJob"){
         before = {
            new GetJobCommand().fixParamNames( params )
         }
      }
      create(controller:"job", action:"create"){
         before = {
            new CreateJobCommand().fixParamNames( params )
         }
      }

/*      all(controller:'*', action:'*') {
         before = {

         }
         after = { Map model ->

         }
         afterView = { Exception e ->

         }
      }
*/
   }
}
