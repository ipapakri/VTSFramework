// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)
#uses "classes/CNS/CnsNode"


//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
*/
class TreeNavigator
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public TreeNavigator(shape treeWidget)/*,
                       string cnsView)*/
  {
    this.treeWidget = treeWidget;
    treeWidget.addColumn("Name");
    treeWidget.expandToDepth(2);
    treeWidget.adjustColumn(0);
  }

  public void select(string id)
  {
    treeWidget.setSelectedItem(id, true);
  }

  public void setVisible(string id, bool visible)
  {
    treeWidget.setVisible(id, visible);
  }

  public void setIcon(string id, string icon)
  {
    treeWidget.setIcon(id, 0, icon);
  }

  public dyn_string children(string id)
  {
    return treeWidget.children(id);
  }

  public void clear()
  {
    treeWidget.clear();
  }

  public void populate(shared_ptr<CnsNode> node, string parentId = "")
  {
    treeWidget.showHeader(false);
    treeWidget.setSorting(0, TRUE);
    //TREE1.setSelectedItem(rootId);
    addNode(node, parentId);
    //tree.expandToDepth(2);
    treeWidget.expandAll();
    treeWidget.adjustColumn(0);
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------

  private void addNode(shared_ptr<CnsNode> node, string parentId = "")
  {
    treeWidget.appendItemNC(
      parentId,
      node.cnsPath,
      node.label
    );
    connectAlarmNode(node.cnsPath);

    for (int i = 1; i <= dynlen(node.children); i++)
    {
      populate(
        node.children[i],
        node.cnsPath
      );
    }
  }

  private void connectAlarmNode(string node)
  {
    string dp;
    cnsGetId(node, dp);
    if(dpExists(dp + ".Internal.Comm"))
    {
      dpConnectUserData("ShowConnectionCB", node,
                         dp + ".Internal.Comm");
    }
  }

  private void ShowConnectionCB(string node,
                                string strDP1, bool value)
  {
    synchronized(nodeImagesMutex)
    {
      if (value)
      {
        nodeImages[node] = "themes/modern/StandardIcons/plc_disconnected_failure_20.png";
      }
      else
      {
        nodeImages[node] = "themes/modern/StandardIcons/plc_connected_green_20.png";
      }
    }

    updateImage(node);
  }

  private void updateImage(string node)
  {
    synchronized(nodeImagesMutex)
    {
      if(mappingHasKey(nodeImages, node))
      {
        treeWidget.setIcon(node, 0, nodeImages[node]);
      }
    }
  }

  private shape treeWidget;
  private uint nodeImagesMutex;
  private mapping nodeImages;
};
