<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="ProcedureSummary.aspx.vb" Inherits="UnisoftERS.ProcedureSummary_aspx" %>

<%@ Register Src="~/Procedure Modules/ScopesAndGuides.ascx" TagName="Scopes" TagPrefix="Proc" %>
<%@ Register Src="~/Procedure Modules/AISoftware.ascx" TagName="AISoftware" TagPrefix="Proc" %>
<%@ Register Src="~/Procedure Modules/DiscomfortScore.ascx" TagName="DiscomfortScore" TagPrefix="Proc" %>
<%@ Register Src="~/Procedure Modules/SedationScore.ascx" TagName="SedationScore" TagPrefix="Proc" %>
<%@ Register Src="~/Procedure Modules/ProcedureExtent.ascx" TagName="ProcedureExtent" TagPrefix="Proc" %>
<%@ Register Src="~/Procedure Modules/ProcedureTimings.ascx" TagName="ProcedureTimings" TagPrefix="Proc" %>
<%@ Register Src="~/Procedure Modules/BowelPrep.ascx" TagName="ProcedureBowelPrep" TagPrefix="Proc" %>
<%@ Register Src="~/Procedure Modules/ProcedureDrugs.ascx" TagName="ProcedureDrugs" TagPrefix="Proc" %>
<%@ Register Src="~/Procedure Modules/DrugsAdministered.ascx" TagName="DrugsAdministered" TagPrefix="Proc" %>

<%@ Register Src="~/Procedure Modules/InsertionTechnique.ascx" TagName="ProcedureInsertionTechnique" TagPrefix="Proc" %>
<%@ Register Src="~/Procedure Modules/Chromendoscopies.ascx" TagName="ProcedureChromendoscopies" TagPrefix="Proc" %>
<%@ Register Src="~/Procedure Modules/Insufflation.ascx" TagPrefix="Proc" TagName="ProcedureInsufflation" %>
<%@ Register Src="~/Procedure Modules/EnteroscopyTechnique.ascx" TagName="ProcedureEnteroscopyTechnique" TagPrefix="Proc" %>
<%@ Register Src="~/Procedure Modules/PlannedExtent.ascx" TagName="PlannedExtent" TagPrefix="Proc" %>
<%@ Register Src="~/Procedure Modules/OGDMucosalOutcomes.ascx" TagName="MucosalVisualisation" TagPrefix="Proc" %>
<%@ Register Src="~/Procedure Modules/Cannulation.ascx" TagName="Cannulation" TagPrefix="Proc" %>
<%@ Register Src="~/Procedure Modules/LevelOfComplexity.ascx" TagName="LevelOfComplexity" TagPrefix="Proc" %>
<%@ Register Src="~/Procedure Modules/Coding.ascx" TagName="Coding" TagPrefix="Proc" %>
<%@ Register Src="~/Procedure Modules/AdditionalReportNotes.ascx" TagName="AdditionalReportNotes" TagPrefix="Proc" %>
<%@ Register Src="~/Procedure Modules/VocalCordParalysis.ascx" TagName="ProcedureVocalCordParalysis" TagPrefix="Proc" %>
<%--add by Ferdowsi--%>
<%@ Register Src="~/Procedure Modules/Management.ascx" TagName="Management" TagPrefix="Proc" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />

    <link href="../../Styles/Site.css" rel="stylesheet" />
    <script src="../../Scripts/jquery-3.6.3.min.js"></script>
    <script src="../../Scripts/global.js"></script>
    <telerik:RadScriptBlock runat="server">
        <script>
            
        </script>
    </telerik:RadScriptBlock>
    <style type="text/css">
        .control-sub-header {
            margin-top: 3px;
            margin-left: 15px;
            font-size: 16px;
            border-bottom: 1px dashed silver;
            width: 50%;
        }

        .control-content {
            padding: 5px 15px 5px 15px;
        }

            .control-content table tr td:first-child {
                padding-right: 10px;
                width: 150px;
                vertical-align: top;
            }
    </style>
    <telerik:RadScriptBlock runat="server">
        <script type="text/javascript">
            function getCookie(cname) {
                let name = cname + "=";
                let ca = document.cookie.split(';');
                for (let i = 0; i < ca.length; i++) {
                    let c = ca[i];
                    while (c.charAt(0) == ' ') {
                        c = c.substring(1);
                    }
                    if (c.indexOf(name) == 0) {
                        return c.substring(name.length, c.length);
                    }
                }
                return "";
            }

            function DisplayProcedureInfo() {
                var procID = '<%=Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>';
                var patientId = parseInt(getCookie('patientId'));
                var appVersion = '<%=Session(UnisoftERS.Constants.SESSION_APPVERSION)%>';
                var operatingHospital = '<%=Session("OperatingHospitalID")%>';
                var userID = '<%=Session("UserID")%>';
                var roomID = '<%=Session("RoomId")%>';
                var imagePortId = '<%=Session("PortId")%>';
                var imagePortName = '<%=Session("PortName")%>';
             //  alert('App Version: ' + appVersion + '\nPatientID: ' + patientID + '\nProcedureID: ' + procID + '\nOperatingHospital: ' + operatingHospital + '\nUserID: ' + userID + '\nRoomID: ' + roomID + '\nPortId: ' + imagePortId + '\nPortName: ' + imagePortName);
            }

            function setRehideSummary() {
                parent.setRehideSummary();
            }
        </script>
    </telerik:RadScriptBlock>
</head>
<body style="margin-bottom: 25px !important">
    <form id="form1" runat="server">

        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Metro" />
        <div id="ContentDiv" style="font-family: 'Segoe UI',Arial,Helvetica,sans-serif; font-size: 12px;">
            <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
            <div id="ProcTimingsDiv" class="procedure-control" ondblclick="DisplayProcedureInfo()" tabindex="-1">
                <div class="control-section-header abnorHeader">Procedure Timings&nbsp;<img src="../../Images/NEDJAG/Ned.png" alt="NED Field" /></div>
                <Proc:ProcedureTimings ID="ProcTimings" runat="server" />
            </div>
            <div class="procedure-control">
                <div class="control-section-header abnorHeader">Instruments and Guides&nbsp;<img src="../../Images/NEDJAG/Ned.png" alt="NED Field" /></div>
                <div id="scopes" tabindex="-1">
                    <Proc:Scopes ID="ProcScopes" runat="Server" OnScope_Changed="ProcScopes_Changed" />
                </div>
                <div id="AISoftware" runat="server">
                    <Proc:AISoftware ID="ProcAISoftware" runat="Server" />
                </div>


                <div id="chromendoscopies">
                    <Proc:ProcedureChromendoscopies ID="ProcChromendoscopies" runat="Server" />
                </div>
                <div id="insufflation" tabindex="-1">
                    <Proc:ProcedureInsufflation ID="ProcInsufflation" runat="Server" />
                </div>
                <div id="insertiontechniques" tabindex="-1">

                    <Proc:ProcedureInsertionTechnique ID="ProcInsertionTechnique" runat="Server" />
                </div>
            </div>

            <div class="procedure-control">
                <div id="ProcedureVocalCordParalysis" runat="server" visible="false">
                    <Proc:ProcedureVocalCordParalysis ID="ProcVocalCordParalysis" runat="Server" />
                </div>
            </div>
            <div class="procedure-control">
                <Proc:Cannulation ID="ProcCannulation" runat="server" />
            </div>
            <div class="procedure-control" id="ProcedureSuccessDiv" runat="server">
                <div class="control-section-header abnorHeader">Procedure success</div>

                <div class="control-sub-header" id="VisualisationLabel" runat="server">Visualisation&nbsp;<img src="../../Images/NEDJAG/JAG.png" alt="JAG Mandatory Field" /></div>
                <div id="enteroscopytechniques" tabindex="-1">
                    <Proc:ProcedureEnteroscopyTechnique ID="ProcEnteroscopyTechnique" runat="Server" />
                </div>
                <div id="mucosalvisualisation" tabindex="-1">
                    <Proc:MucosalVisualisation ID="ProcMucosalVisualisation" runat="server" />
                </div>

                <div id="extentdiv" runat="server" tabindex="-1" clientidmode="Static">
                    <div class="control-sub-header" id="ExtentofIntubationSection" runat="server">Extent of intubation&nbsp;<img src="../../Images/NEDJAG/JAGNED.png" alt="NED Field" /></div>
                    <Proc:PlannedExtent ID="ProcPlannedExtent" runat="server" />
                    <Proc:ProcedureExtent ID="ProcProcedureExtent" runat="Server" />
                </div>
            </div>
            <div class="procedure-control">

                <Proc:LevelOfComplexity ID="ProcLevelOfComplexity" runat="Server" />
            </div>
            <div id="bowelprep" tabindex="-1">
                <Proc:ProcedureBowelPrep ID="ProcBowelPrep" runat="Server" />
            </div>
           <div id="proceduredrugs" tabindex="-1">
                <Proc:ProcedureDrugs ID="ProcDrugsAdministered" runat="Server" />
            </div>
            <div id="broncsdrugs" tabindex="-1">
                <Proc:DrugsAdministered ID="ProcBroncDrugsAdministered" runat="server" Visible="false" />
            </div>
           <%--  <div class="control-section-header abnorHeader">Procedure success</div>--%>
             <div class="control-sub-header">Patient Management&nbsp;<img src="../../Images/NEDJAG/JAGNEDMand.png" alt="All Mandatory Field" /></div>
            <div id="management" tabindex="-1">
                <Proc:Management ID="ProcManagement" runat="Server" />
            </div>
            <div id="sedationscore" class="procedure-control">
                <div class="control-sub-header">Sedation score&nbsp;<img src="../../Images/NEDJAG/JAGNEDMand.png" alt="All Mandatory Field" class="general-aneathetic-mandatory-remove"/></div>
                <Proc:SedationScore ID="ProcSedationScore" runat="Server" />
            </div>
            <div id="procedurediscomfort" class="procedure-control" tabindex="-1">
                <div class="control-sub-header" id="ProcedureDiscomfortSection" runat="server">Procedure discomfort&nbsp;<img src="../../Images/NEDJAG/JAGNEDMand.png" alt="All Mandatory Field" /></div>
                <Proc:DiscomfortScore ID="ProcDiscomfortScore" runat="Server" />
            </div>
            <div id="AdditionalReportNotesDiv" class="procedure-control" runat="server" visible="false" tabindex="-1">
                <Proc:AdditionalReportNotes ID="ProcAdditionalReportNotes" runat="Server" />
            </div>
            <div id="BronchoCodingDiv" class="procedure-control" runat="server" visible="false" tabindex="-1">
                <Proc:Coding ID="ProcBronchCoding" runat="Server" />
            </div>
        </div>
    </form>
</body>
</html>
