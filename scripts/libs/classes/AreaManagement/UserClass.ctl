// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)
#uses "classes/AreaManagement/UserArea.ctl"
//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
*/
class UserClass
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public UserClass(string name, mapping areas)
  {
    this.name = name;
    initialize(areas);
  }

  public string getName()
  {
    return this.name;
  }

  private void initialize(mapping areas)
  {
    dyn_string areasLocal;
    dyn_int permissionsLocal;
    dpGet(this.name + ".Areas", areasLocal,
          this.name + ".Permissions", permissionsLocal);

    for(int i=1; i<=dynlen(areasLocal); i++)
    {
      shared_ptr<UserArea> userArea = new UserArea(areas[areasLocal[i]], permissionsLocal[i]);
      this.areas[areasLocal[i]] = userArea;
    }
  }

  public bool hasPermission(string area, int permission)
  {
    if(!mappingHasKey(this.areas, area))
    {
      return false;
    }
    return getBit(this.areas[area].getPermission(), permission) == 1;
  }

  public mapping getAreas()
  {
    return areas;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------
  private string name;
  private mapping areas;
};
