// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)
#uses "classes/navigation/NavigationTarget"
#uses "classes/navigation/NavigationView"


//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
  Process-panel surface. Opens panelFile in the given embedded module.
  Targets without a panel are a no-op.
*/
class PanelNavigator : NavigationView
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public PanelNavigator(shape embeddedModule)
  {
    this.embeddedModule = embeddedModule;
  }

  public bool apply(shared_ptr<NavigationTarget> target)
  {
    if (target == nullptr)
      return false;

    if (!target.hasPanel())
      return true;

    DebugTN(__FILE__, __FUNCTION__, __LINE__, target);

    return showPanel(target.panelFile, target.panelParameters);
  }

  public bool showPanel(string panelFile, dyn_string parameters)
  {
    if (panelFile == "")
      return true;

    string moduleName = embeddedModule.ModuleName();
    if (moduleName == "")
    {
      DebugTN(__FILE__, __FUNCTION__, __LINE__, "PanelNavigator has no module name");
      return false;
    }

    int rc = RootPanelOnModule(panelFile, "", moduleName, parameters);
    return rc == 0;
  }

  public shape getEmbeddedModule()
  {
    return this.embeddedModule;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
  private shape embeddedModule;
};
