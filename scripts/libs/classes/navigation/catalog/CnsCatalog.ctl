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
#uses "classes/CNS/CnsRepository.ctl"
#uses "classes/navigation/NavigationCatalog"
#uses "classes/navigation/NavigationTarget"


//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
  CNS-backed catalog. Indexes a loaded CNS tree as NavigationTargets.
*/
class CnsCatalog : NavigationCatalog
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public CnsCatalog()
  {
  }

  /**
    Load a CNS view, index every node, and return the tree root for the tree view.
  */
  public shared_ptr<CnsNode> loadView(string viewPath)
  {
    CnsRepository repository;
    shared_ptr<CnsNode> root = repository.loadView(viewPath);

    if (root == nullptr)
      return nullptr;

    buildFromRoot(root);
    return root;
  }

  /**
    The CNS root node, for callers that need the CNS tree itself rather than
    the navigation view of it.
  */
  public shared_ptr<CnsNode> getRoot()
  {
    return root;
  }

  public string getRootId()
  {
    return rootId;
  }

  public dyn_string getChildIds(string id)
  {
    if (mappingHasKey(childIds, id))
      return childIds[id];

    return makeDynString();
  }

  public dyn_string getAllIds()
  {
    dyn_string ids;
    dyn_anytype keys = mappingKeys(targets);

    for (int i = 1; i <= dynlen(keys); i++)
    {
      dynAppend(ids, (string)keys[i]);
    }

    return ids;
  }

  public shared_ptr<NavigationTarget> resolve(string id)
  {
    if (id == "" || !mappingHasKey(targets, id))
    {
      DebugTN(__FILE__, __FUNCTION__, __LINE__, "Target not in catalog: " + id);
      return nullptr;
    }

    return targets[id];
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------

  private void buildFromRoot(shared_ptr<CnsNode> root)
  {
    targets = makeMapping();
    childIds = makeMapping();
    rootId = "";
    this.root = root;

    if (root == nullptr)
      return;

    rootId = root.getCnsPath();
    indexNode(root, "");
  }

  private void indexNode(shared_ptr<CnsNode> node, string parentId)
  {
    if (node == nullptr || node.getCnsPath() == "")
      return;

    string id = node.getCnsPath();

    shared_ptr<NavigationTarget> target = toTarget(node);
    target.setParentId(parentId);
    targets[id] = target;

    dyn_string ids;
    dyn_anytype children = node.getChildren();

    for (int i = 1; i <= dynlen(children); i++)
    {
      shared_ptr<CnsNode> child = children[i];

      if (child == nullptr || child.getCnsPath() == "")
        continue;

      dynAppend(ids, child.getCnsPath());
      indexNode(child, id);
    }

    childIds[id] = ids;
  }

  private shared_ptr<NavigationTarget> toTarget(shared_ptr<CnsNode> node)
  {
    shared_ptr<NavigationTarget> target = new NavigationTarget();

    target.setId(node.getCnsPath());
    target.setLabel(node.getLabel());
    target.setDatapoint(node.getDp());
    target.setHasLocation(node.getHasLocation());
    target.setLatitude(node.getLat());
    target.setLongitude(node.getLon());
    target.setAltitude(node.getAlt());
    target.setPanelFile(node.getPanelFile());
    target.setPanelParameters(node.getPanelParameters());

    return target;
  }

  private shared_ptr<CnsNode> root;
  private string rootId;
  private mapping targets;
  private mapping childIds;
};
