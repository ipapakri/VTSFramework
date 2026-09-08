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
#uses "classes/navigation/NavigationTarget"
#uses "classes/navigation/NavigationView"


//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
  Generic tree surface. Product-specific extras (PLC icons, area filtering, ...)
  belong in a subclass that overrides onNodeAdded().
*/
class TreeNavigator : NavigationView
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public TreeNavigator(shape treeWidget)
  {
    this.treeWidget = treeWidget;
    treeWidget.addColumn("Name");
    treeWidget.expandToDepth(2);
    treeWidget.adjustColumn(0);
  }

  public bool apply(shared_ptr<NavigationTarget> target)
  {
    if (target == nullptr)
      return false;

    select(target.id);
    return true;
  }

  public void select(string id)
  {
    if (treeWidget.selectedItem() == id)
    {
      return;
    }

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
    addNode(node, parentId);
    treeWidget.expandAll();
    treeWidget.adjustColumn(0);
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

  /**
    Called after each tree item is created. Default is a no-op.
    Subclasses attach comms icons, hide unauthorized nodes, etc. here.
  */
  protected void onNodeAdded(shared_ptr<CnsNode> node)
  {
  }

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------

  private void addNode(shared_ptr<CnsNode> node, string parentId = "")
  {
    if (node == nullptr)
      return;

    treeWidget.appendItemNC(
      parentId,
      node.cnsPath,
      node.label
    );
    onNodeAdded(node);

    for (int i = 1; i <= dynlen(node.children); i++)
    {
      addNode(
        node.children[i],
        node.cnsPath
      );
    }
  }

  private shape treeWidget;
};
