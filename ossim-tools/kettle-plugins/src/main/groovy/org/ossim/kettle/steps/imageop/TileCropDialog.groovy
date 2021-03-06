package org.ossim.kettle.steps.imageop

import org.eclipse.swt.SWT
import org.eclipse.swt.widgets.Display
import org.eclipse.swt.widgets.MessageBox
import org.eclipse.swt.widgets.Shell
import org.ossim.kettle.groovyswt.KettleSwtBuilder
import org.ossim.kettle.types.OssimValueMetaBase
import org.ossim.kettle.utilities.SwtUtilities
import org.pentaho.di.core.Const
import org.pentaho.di.core.row.value.ValueMetaBase
import org.pentaho.di.trans.TransMeta
import org.pentaho.di.trans.step.BaseStepMeta
import org.pentaho.di.trans.step.StepDialogInterface
import org.pentaho.di.ui.trans.step.BaseStepDialog

/**
 * Created by gpotts on 6/3/15.
 */
class TileCropDialog extends BaseStepDialog implements
        StepDialogInterface
{
   private TileCropMeta input;
   private def swt;

   public TileCropDialog(Shell parent, Object baseStepMeta,
                         TransMeta transMeta, String stepname)
   {
      super(parent, (BaseStepMeta) baseStepMeta, transMeta, stepname);
      input = (TileCropMeta) baseStepMeta;
   }

   public String open()
   {
      Shell parent = getParent();
      Display display = parent.getDisplay();
      swt = new KettleSwtBuilder()
      shell = swt.shell(parent) {
         migLayout(layoutConstraints: "insets 2, wrap 1", columnConstraints: "[grow]")
         group(layoutData: "span,growx") {
            migLayout(layoutConstraints: "insets 2, wrap 2", columnConstraints: "[] [grow]")
            //gridLayout(numColumns: 2)
            label Messages.getString("TileCropDialog.Stepname.Label")

            //text(id:"stepName", text: stepname ,layoutData:"span, growx"){
            text(id: "stepName", layoutData: "span,growx", text: stepname) {
               onEvent(type: 'Modify') { changed=true }
            }
         }
         group(id: "cropDefinitionsGroupId", text: "Crop definitions", style: "none", layoutData: "span,growx") {
            migLayout(layoutConstraints: "insets 2, wrap 2", columnConstraints: "[] [grow]")
            label "Aoi"
            cCombo(id: "aoiField",
                    items: SwtUtilities.previousStepFields(transMeta, stepname, [OssimValueMetaBase.TYPE_GEOMETRY_2D]),
                    layoutData: "span,growx")
                    {
                       onEvent(type: 'Modify') {
                          changed=true
                       }
                    }
            label "Tile Aoi"
            cCombo(id: "tileAoiField",
                    items: SwtUtilities.previousStepFields(transMeta, stepname, [OssimValueMetaBase.TYPE_GEOMETRY_2D]),
                    layoutData: "span,growx")
                    {
                       onEvent(type: 'Modify') {
                          changed=true
                       }
                    }
            label "Tile"
            cCombo(id: "tileField",
                    items: SwtUtilities.previousStepFields(transMeta, stepname, [OssimValueMetaBase.TYPE_IMAGE, OssimValueMetaBase.TYPE_CLONABLE_IMAGE]),
                    layoutData: "span,growx")
                    {
                       onEvent(type: 'Modify') {
                          changed=true
                       }
                    }
            label Messages.getString("TileCropDialog.PassNullTiles.Label")
            checkBox(id: "passNullTiles",
                    text: "",
                    selection: true,
                    layoutData: "span, growx, wrap") {
               onEvent(type: "Selection") {
                  changed=true

               }
            }
            label Messages.getString("TileCropDialog.PassEmptyTiles.Label")
            checkBox(id: "passEmptyTiles",
                    text: "",
                    selection: true,
                    layoutData: "span, growx, wrap") {
               onEvent(type: "Selection") {
                  changed=true
               }
            }
         }
         group(layoutData: "span,growx") {
            migLayout(layoutConstraints: "insets 2, wrap 2", columnConstraints: "[] [grow]")
            button("Ok", layoutData: "align center,skip 1,split 2") {
               onEvent(type: "Selection") { ok() }
            }
            button("Cancel", layoutData: "") {
               onEvent(type: "Selection") { cancel() }
            }

         }
      }
      changed = input.hasChanged();

      shell.text = Messages.getString("TileCropDialog.Shell.Title")
      getData(); // initialize data fields
      setSize(); // shrink and fit dialog to fit inputs
      shell.doMainloop()

      return stepname;
   }

   public void getData()
   {
      swt.stepName.selectAll()

      swt.aoiField.text     = input.aoiField?:""
      swt.tileAoiField.text = input.tileAoiField?:""
      swt.tileField.text    = input.tileField?:""
      swt.passNullTiles.selection  = input.passNullTiles
      swt.passEmptyTiles.selection = input.passEmptyTiles
   }

   private void cancel()
   {
      stepname = null

      dispose()
   }

   private void ok()
   {
      if (Const.isEmpty(swt.stepName.text)){
         MessageBox mb = new MessageBox(shell, SWT.OK | SWT.ICON_ERROR );
         mb.message = "Stepname empty"; //$NON-NLS-1$
         mb.text = "Stepname empty" //$NON-NLS-1$
         mb.open()
         return;
      }

      stepname = swt.stepName.text

      input.aoiField     = swt.aoiField.text
      input.tileAoiField = swt.tileAoiField.text
      input.tileField    = swt.tileField.text

      input.passNullTiles  = swt.passNullTiles.selection
      input.passEmptyTiles = swt.passEmptyTiles.selection

      input.setChanged(changed)

      dispose()
   }
}