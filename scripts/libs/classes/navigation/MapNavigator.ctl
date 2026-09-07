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
  Map surface. mapWidget should be the Map EWO (the object that provides centerOn).
*/
class MapNavigator : NavigationView
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public MapNavigator(shape mapWidget)
  {
    this.mapWidget = mapWidget;
  }

  public bool apply(shared_ptr<NavigationTarget> target)
  {
    if (!target)
      return false;

    if (!target.hasLocation)
      return true;

    return zoomToPoint(target.latitude, target.longitude, target.altitude);
  }

  public bool zoomToPoint(float latitude, float longitude, float altitude)
  {
    mapWidget.centerOn(latitude, longitude, altitude);
    return true;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
  private shape mapWidget;
};
