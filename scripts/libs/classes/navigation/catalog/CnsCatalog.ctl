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

    if (node.cnsPath != "")
      targets[node.cnsPath] = toTarget(node);

    for (int i = 1; i <= dynlen(node.children); i++)
    {
      indexNode(node.children[i]);
    }
  }

  private shared_ptr<NavigationTarget> toTarget(shared_ptr<CnsNode> node)
  {
    shared_ptr<NavigationTarget> target = new NavigationTarget();

    target.id = node.cnsPath;
    target.label = node.label;
    target.datapoint = node.dp;
    target.hasLocation = node.hasLocation;
    target.latitude = node.lat;
    target.longitude = node.lon;
    target.altitude = node.alt;
    target.panelFile = node.panelFile;
    target.panelParameters = node.panelParameters;

    return target;
  }

  private shared_ptr<CnsNode> root;
  private mapping targets;
};
