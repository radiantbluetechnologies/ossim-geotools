package org.ossim.kettle.steps.dirwatch

import org.pentaho.di.core.row.RowMetaInterface
import org.pentaho.di.trans.step.BaseStepData
import org.pentaho.di.trans.step.StepDataInterface



class DirWatchData extends BaseStepData implements StepDataInterface
{
   public RowMetaInterface outputRowMeta;

   public DirWatchData()
   {
      super();
   }
}