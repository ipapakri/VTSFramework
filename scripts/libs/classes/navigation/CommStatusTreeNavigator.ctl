// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)
#uses "classes/CNS/CnsNode.ctl"
#uses "classes/navigation/TreeNavigator"


//--------------------------------------------------------------------------------
// Variables and Constants
const string COMM_STATUS_DPE = ".Internal.Comm";
const string ICON_PLC_DISCONNECTED = "themes/modern/StandardIcons/plc_disconnected_failure_20.png";
const string ICON_PLC_CONNECTED = "themes/modern/StandardIcons/plc_connected_green_20.png";

//--------------------------------------------------------------------------------
/**
  Project/domain tree: shows PLC comms status on nodes that have .Internal.Comm.
  Use this instead of TreeNavigator when the plant model has that datapoint.
*/
class CommStatusTreeNavigator : TreeNavigator
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public CommStatusTreeNavigator(shape treeWidget) : TreeNavigator(treeWidget)
  {
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

  protected void onNodeAdded(shared_ptr<CnsNode> node)
  {
    if (!node || node.dp == "")
      return;

    string commDpe = node.dp + COMM_STATUS_DPE;
    if (!dpExists(commDpe))
      return;

    dpConnectUserData(this, "showConnectionCB", node.cnsPath, commDpe);
  }

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------

  private void showConnectionCB(string nodeId, string dpe, bool disconnected)
  {
    synchronized(nodeImagesMutex)
    {
      if (disconnected)
        nodeImages[nodeId] = ICON_PLC_DISCONNECTED;
      else
        nodeImages[nodeId] = ICON_PLC_CONNECTED;
    }

    updateImage(nodeId);
  }

  private void updateImage(string nodeId)
  {
    synchronized(nodeImagesMutex)
    {
      if (mappingHasKey(nodeImages, nodeId))
        setIcon(nodeId, nodeImages[nodeId]);
    }
  }

  private uint nodeImagesMutex;
  private mapping nodeImages;
};
