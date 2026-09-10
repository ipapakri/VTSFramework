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


//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
  Optional navigation surface (tree, map, panel, ...).
  Register only the views the project has.
*/
class NavigationView
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public NavigationView()
  {
  }

  /**
    Apply the target to this surface.
    Return true on success or intentional no-op (e.g. no location on a map view).
  */
  public bool apply(shared_ptr<NavigationTarget> target)
  {
    throw(makeError("", PRIO_SEVERE, ERR_IMPL, 1, "Method apply is abstract in this context, \"NavigationView\""));
    return false;
  }

  public bool getReady()
  {
    return this.ready;
  }

  /**
    A view that cannot draw yet (an embedded module still loading) reports
    false and stores the target it was given; setReady(true) then replays it
    through onReady().
  */
  public void setReady(bool ready)
  {
    this.ready = ready;

    if (ready)
      onReady();
  }

  /**
    Process-wide unique handle for this view, used by the controller to
    recognise the view a navigation request came from.
  */
  public int getViewId()
  {
    // Assigned lazily rather than in the constructor so that subclasses keep
    // an identity even if they never chain to this base constructor.
    if (viewId == 0)
    {
      nextViewId++;
      viewId = nextViewId;
    }

    return viewId;
  }

  /**
    True when otherViewId denotes this view. Composites and decorators override
    it to also claim the views they wrap, so the controller skips the whole
    group when one of its members started the navigation.
  */
  public bool matchesView(int otherViewId)
  {
    return otherViewId == getViewId();
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

  /**
    Called when the view becomes ready. Default is a no-op.
  */
  protected void onReady()
  {
  }

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
  private bool ready;
  private int viewId;

  private static int nextViewId;
};
