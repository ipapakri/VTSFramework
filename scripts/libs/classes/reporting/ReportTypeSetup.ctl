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
  Creates _ReportDefinition and _ReportJob if they are missing. Called once
  from the report CTRL manager before the queue starts.
*/
class ReportTypeSetup
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  public static const string DEFINITION_DPT = "_ReportDefinition";
  public static const string JOB_DPT = "_ReportJob";

  public static bool ensureTypes()
  {
    bool ok = true;

    if (!typeExists(DEFINITION_DPT))
      ok = createDefinitionType() && ok;

    if (!typeExists(JOB_DPT))
      ok = createJobType() && ok;

    return ok;
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------

  private static bool typeExists(string name)
  {
    return dynlen(dpTypes(name)) > 0;
  }

  private static bool createDefinitionType()
  {
    dyn_dyn_string elements;
    dyn_dyn_int types;

    elements[1] = makeDynString(DEFINITION_DPT, "", "");
    types[1] = makeDynInt(DPEL_STRUCT, 0, 0);

    elements[2] = makeDynString("", "Header", "");
    types[2] = makeDynInt(0, DPEL_STRUCT, 0);
    elements[3] = makeDynString("", "", "Title");
    types[3] = makeDynInt(0, 0, DPEL_LANGSTRING);
    elements[4] = makeDynString("", "", "ReportType");
    types[4] = makeDynInt(0, 0, DPEL_STRING);
    elements[5] = makeDynString("", "", "Template");
    types[5] = makeDynInt(0, 0, DPEL_STRING);
    elements[6] = makeDynString("", "", "LogoPath");
    types[6] = makeDynInt(0, 0, DPEL_STRING);
    elements[7] = makeDynString("", "", "OutputDir");
    types[7] = makeDynInt(0, 0, DPEL_STRING);

    elements[8] = makeDynString("", "Sections", "");
    types[8] = makeDynInt(0, DPEL_STRUCT, 0);
    elements[9] = makeDynString("", "", "Numbers");
    types[9] = makeDynInt(0, 0, DPEL_DYN_INT);
    elements[10] = makeDynString("", "", "Titles");
    types[10] = makeDynInt(0, 0, DPEL_DYN_LANGSTRING);
    elements[11] = makeDynString("", "", "SignalSuffix");
    types[11] = makeDynInt(0, 0, DPEL_DYN_STRING);
    elements[12] = makeDynString("", "", "ProviderKey");
    types[12] = makeDynInt(0, 0, DPEL_DYN_STRING);

    elements[13] = makeDynString("", "Schedule", "");
    types[13] = makeDynInt(0, DPEL_STRUCT, 0);
    elements[14] = makeDynString("", "", "Enabled");
    types[14] = makeDynInt(0, 0, DPEL_BOOL);
    elements[15] = makeDynString("", "", "Boundaries");
    types[15] = makeDynInt(0, 0, DPEL_DYN_STRING);

    int error = dpTypeCreate(elements, types);
    if (error != 0)
    {
      DebugTN(__FILE__, __FUNCTION__, __LINE__, "dpTypeCreate failed", DEFINITION_DPT, error);
      return false;
    }

    return true;
  }

  private static bool createJobType()
  {
    dyn_dyn_string elements;
    dyn_dyn_int types;

    elements[1] = makeDynString(JOB_DPT, "", "");
    types[1] = makeDynInt(DPEL_STRUCT, 0, 0);

    elements[2] = makeDynString("", "Request", "");
    types[2] = makeDynInt(0, DPEL_STRUCT, 0);
    elements[3] = makeDynString("", "", "DefinitionId");
    types[3] = makeDynInt(0, 0, DPEL_STRING);
    elements[4] = makeDynString("", "", "StationDps");
    types[4] = makeDynInt(0, 0, DPEL_DYN_STRING);
    elements[5] = makeDynString("", "", "From");
    types[5] = makeDynInt(0, 0, DPEL_TIME);
    elements[6] = makeDynString("", "", "To");
    types[6] = makeDynInt(0, 0, DPEL_TIME);
    elements[7] = makeDynString("", "", "User");
    types[7] = makeDynInt(0, 0, DPEL_STRING);
    elements[8] = makeDynString("", "", "Trigger");
    types[8] = makeDynInt(0, 0, DPEL_BOOL);

    elements[9] = makeDynString("", "Result", "");
    types[9] = makeDynInt(0, DPEL_STRUCT, 0);
    elements[10] = makeDynString("", "", "State");
    types[10] = makeDynInt(0, 0, DPEL_INT);
    elements[11] = makeDynString("", "", "PdfPath");
    types[11] = makeDynInt(0, 0, DPEL_STRING);
    elements[12] = makeDynString("", "", "Error");
    types[12] = makeDynInt(0, 0, DPEL_STRING);

    int error = dpTypeCreate(elements, types);
    if (error != 0)
    {
      DebugTN(__FILE__, __FUNCTION__, __LINE__, "dpTypeCreate failed", JOB_DPT, error);
      return false;
    }

    return true;
  }
};
