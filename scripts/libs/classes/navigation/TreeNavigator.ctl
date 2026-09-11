// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)
#uses "classes/navigation/NavigationCatalog"
#uses "classes/navigation/NavigationTarget"
#uses "classes/navigation/NavigationView"


//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
  Generic tree surface over any NavigationCatalog hierarchy. Product-specific
  extras belong in a subclass: decoration per item goes in onNodeAdded(), and
  anything that depends on the finished tree (hiding nodes a user may not see,
  and so collapsing the branches left empty) walks it afterwards through
  children() and setVisible(), starting from the protected rootId.

  The panel wiring is expected to pass this view as the navigation source:

    selectionChanged(string id)
    {
      navigationController.navigate(id, treeView);
    }
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

    select(target.getId());
    return true;
  }

  public void select(string id)
  {
    // Cheap short-circuit only. setSelectedItem() re-emits selectionChanged,
    // and it is the controller that refuses to re-enter on the way back.
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

  public void setBackColor(string id, string color)
  {
    treeWidget.setBackColor(id, 0, color);
  }

  public dyn_string children(string id)
  {
    return treeWidget.children(id);
  }

  public void clear()
  {
    treeWidget.clear();
  }

  /**
    Builds the tree from the catalog hierarchy, starting at rootId or at the
    catalog root when rootId is "".
  */
  public void populate(shared_ptr<NavigationCatalog> catalog, string rootId = "")
  {
    if (catalog == nullptr)
    {
      DebugTN(__FILE__, __FUNCTION__, __LINE__, "Cannot populate tree without a catalog");
      return;
    }

    if (rootId == "")
      rootId = catalog.getRootId();

    this.catalog = catalog;
    this.rootId = rootId;

    treeWidget.showHeader(false);
    treeWidget.setSorting(0, TRUE);
    addNode(catalog, rootId, "");
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
  protected void onNodeAdded(shared_ptr<NavigationTarget> target)
  {
  }

  protected shared_ptr<NavigationCatalog> catalog;
  protected string rootId;

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------

  private void addNode(shared_ptr<NavigationCatalog> catalog, string id, string parentId)
  {
    if (id == "")
      return;

    shared_ptr<NavigationTarget> target = catalog.resolve(id);

    if (target == nullptr)
      return;

    treeWidget.appendItemNC(
      parentId,
      id,
      target.getLabel()
    );
    onNodeAdded(target);

    dyn_string childIds = catalog.getChildIds(id);
    for (int i = 1; i <= dynlen(childIds); i++)
    {
      addNode(
        catalog,
        childIds[i],
        id
      );
    }
  }

  private shape treeWidget;
};
