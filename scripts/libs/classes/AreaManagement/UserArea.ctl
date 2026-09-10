// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)
#uses "classes/AreaManagement/Area.ctl"
//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
*/
class UserArea
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public UserArea(shared_ptr<Area> area, int permission)
  {
    this.area = area;
    this.permission = permission;
  }

  public shared_ptr<Area> getArea()
  {
    return this.area;
  }

  public int getPermission()
  {
    return this.permission;
  }

  public bool hasPermission(int permissionToCheck)
  {
    return this.permission == permissionToCheck;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------

  private shared_ptr<Area> area;
  private int permission;

};
