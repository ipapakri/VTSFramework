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

  private void buildFromRoot(shared_ptr<CnsNode> root)
  {
    targets = makeMapping();
    this.root = root;

    if(root != nullptr)
    {
      indexNode(root);
    }
  }

  public shared_ptr<CnsNode> getRoot()
  {
    return root;
  }

  public shared_ptr<NavigationTarget> resolve(string id)
  {
    bool found = (id != "" && mappingHasKey(targets, id));
    string targetId;
    if (found)
    {
      shared_ptr<NavigationTarget> t = targets[id];
      targetId = t.getId();
    }
    DebugTN("CATALOG", "asked", id, "found", found, "target.id", targetId, targets[id].getId(),
            "mismatch", found && (targetId != id), targets[id]);

    if (id == "" || !mappingHasKey(targets, id))
    {
      DebugTN(__FILE__, __FUNCTION__, __LINE__, "Target not in catalog: " + id);
      return nullptr;
    }

    shared_ptr<NavigationTarget> target = targets[id];
    return target;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------

  private void indexNode(shared_ptr<CnsNode> node)
  {
    if (node == nullptr)
      return;

    if (node.getCnsPath() != "")
      targets[node.getCnsPath()] = toTarget(node);

    dyn_anytype children = node.getChildren();
    for (int i = 1; i <= dynlen(children); i++)
    {
      indexNode(children[i]);
    }
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
  private mapping targets;
};
