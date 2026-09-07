// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)

//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
  Destination resolved by a catalog. Views use only the fields they understand.
  Missing location or panel is a no-op for that view, not a failed navigation.
*/
class NavigationTarget
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------
  public string id;
  public string label;
  public string datapoint;

  public bool hasLocation;
  public float latitude;
  public float longitude;
  public float altitude;

  public string panelFile;
  public dyn_string panelParameters;

  public mapping extras;

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public NavigationTarget()
  {
  }

  public bool hasPanel()
  {
    return panelFile != "";
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
};
