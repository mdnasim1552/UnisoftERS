<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Common_PrintReport" CodeBehind="PrintReport.aspx.vb" %>

<%@ Register TagPrefix="unisoft" TagName="Diagram" Src="~/UserControls/diagram.ascx" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Print Report</title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../Scripts/raphael-min.js"></script>
    <script type="text/javascript" src="../../Scripts/global.js"></script>
    <script type="text/javascript" src="../../Scripts/diagramReport.js"></script>

    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <link type="text/css" href="../../Styles/PrintReport.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {

        });

        function CloseWindow() {
            GetRadWindow().close();
        }

        function GetRadWindow() {
            var oWindow = null; if (window.radWindow)
                oWindow = window.radWindow; else if (window.frameElement.radWindow)
                oWindow = window.frameElement.radWindow; return oWindow;
        }

        $(window).on('load', function () {

        });
    </script>

    <style type="text/css">
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="PrintRadScriptManager" runat="server" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />

        <unisoft:Diagram ID="Diagram1" runat="server" />

        <asp:ObjectDataSource ID="SummaryObjectDataSource" runat="server" SelectMethod="GetPrintReport" TypeName="UnisoftERS.DataAccess"></asp:ObjectDataSource>
        <asp:ObjectDataSource ID="SummaryObjectDataSourceRightSide" runat="server" SelectMethod="GetPrintReport" TypeName="UnisoftERS.DataAccess"></asp:ObjectDataSource>
        <asp:ObjectDataSource ID="SummaryObjectDataSourceAfterDiagram" runat="server" SelectMethod="GetPrintReport" TypeName="UnisoftERS.DataAccess"></asp:ObjectDataSource>
        <asp:ObjectDataSource ID="SummaryObjectDataSourcePhotos" runat="server" SelectMethod="GetPrintReportPhotos" TypeName="UnisoftERS.DataAccess"></asp:ObjectDataSource>
        <asp:ObjectDataSource ID="SummaryObjectDataSourceSpecimens" runat="server" SelectMethod="GetPrintReportSpecimens" TypeName="UnisoftERS.DataAccess"></asp:ObjectDataSource>

        <div id="divLogoAndTitle" runat="server" style="width: 100%; margin-top: 15px; height: 85px;">
            <%--<asp:Image ID="PhotoImage" runat="server" ImageUrl='<%# Eval("PhotoUrl") %>' ToolTip='<%# Eval("PhotoUrl") %>' class="PhotoImageWidth"/>--%>
            <table id="tbldivLogoAndTitle" runat="server" class="mainTable printFontBasic" cellpadding="0" cellspacing="0" style="height: 85px;">
                <tr>
                    <td width="25%" align="left" valign="top">
                        <asp:Image ID="HeaderLeftLogoPath" Width="145" Height="60" runat="server" />
                    </td>
                    <td width="50%" align="center" valign="bottom">
                        <asp:Label ID="HeaderTitle" runat="server" Font-Size="16pt" Font-Bold="true" class="printFontBasic" />
                    </td>
                    <td width="25%" align="right" valign="top">
                        <asp:Image ID="HeaderRightLogoPath" Width="145" Height="60" runat="server" />
                    </td>
                </tr>
            </table>
        </div>
        <%--GP Report--%>
        <div id="divGPRepHeader" runat="server" style="width: 100%;">
            <table id="tblGPRepHeader" runat="server" class="mainTable printFontBasic" cellpadding="0" cellspacing="0" style="line-height: 1;">
                <tr>
                    <td width="15%" class="printFontBasic">Name:</td>
                    <td width="35%">
                        <asp:Label ID="NameLabel" runat="server" Text="" Font-Bold="true" class="printFontBasic" /></td>
                    <td rowspan="4" width="10%"></td>
                    <td width="20%" class="printFontBasic">Address:</td>
                    <td rowspan="4" valign="top" width="25%">
                        <asp:Label ID="AddressLabel" runat="server" Text="" Font-Bold="true" class="printFontBasic" /></td>
                </tr>
                <tr>
                    <td class="printFontBasic">Date of birth:</td>
                    <td>
                        <asp:Label ID="DobLabel" runat="server" Text="" Font-Bold="true" class="printFontBasic" /></td>
                </tr>
                <tr>
                    <td>
                        <asp:Label ID="lblNHSNo" runat="server" Text="<%=Session(Constants.SESSION_HEALTH_SERVICE_NAME).ToString() %> No" class="printFontBasic" />: </td>
                    <td>
                        <asp:Label ID="NhsNoLabel" runat="server" Text="" Font-Bold="true" class="printFontBasic" /></td>
                </tr>
                <tr>
                    <td valign="top">
                        <asp:Label ID="lblCaseNoteNo" runat="server" Text="Hospital no" class="printFontBasic" />:</td>
                    <td valign="top">
                        <asp:Label ID="CaseNoteNoLabel" runat="server" Text="" Font-Bold="true" class="printFontBasic" /></td>
                </tr>
                <%--<tr>
                    <td colspan="6">
                        <hr style="height: 0.2px; border: none; color: black;" />
                    </td>
                </tr>--%>
            </table>
        </div>

        <div id="GPReportDiv" runat="server" style="width: 100%;">
            <table class="mainTable printFontBasic" cellpadding="0" cellspacing="0">
                <tr style="padding-bottom: 10px; margin-bottom: 20px;">
                    <td valign="top" style="width: 5%; border-left: 23px; border-color: white" class="printFontBasic">GP:</td>
                    <td valign="top" style="text-align: left; width: 35%;">
                        <asp:Label ID="GPAddressLabel" runat="server" Font-Bold="true" class="printFontBasic" /></td>

                    <td colspan="2" valign="top" style="text-align: right;">
                        <table class="printFontBasic" style="width: 105%;">
                            <tr>
                                <td valign="top" width="52%" style="text-align: right" class="printFontBasic">Procedure Date:</td>
                                <td valign="top" width="48%" class="textalignright">
                                    <asp:Label ID="ProcedureDateLabel" runat="server" Text="" Font-Bold="true" class="printFontBasic" /></td>
                            </tr>
                            <tr>
                                <td valign="top" class="printFontBasic textalignright" >Priority:</td>
                                <td valign="top" class="textalignright">
                                    <asp:Label ID="PriorityLabel" runat="server" Text="" Font-Bold="true" class="printFontBasic" /></td>
                            </tr>
                            <tr>
                                <td valign="top" class="printFontBasic textalignright">Status:</td>
                                <td valign="top" class="textalignright">
                                    <asp:Label ID="StatusLabel" runat="server" Text="" Font-Bold="true" class="printFontBasic" /></td>
                            </tr>
                            <tr id="TRReferringHospital" runat="server">
                                <td valign="top" class="printFontBasic textalignright">Referring Hospital:</td>
                                <td valign="top" class="textalignright">
                                    <asp:Label ID="HospitalLabel" runat="server" Text="" Font-Bold="true" class="printFontBasic" /></td>
                            </tr>
                            <tr runat="server" id="trPrintWard">
                                <td valign="top" class="printFontBasic textalignright">Ward:</td>
                                <td valign="top" class="textalignright">
                                    <asp:Label ID="WardLabel" runat="server" Text="" Font-Bold="true" class="printFontBasic" /></td>
                            </tr>
                            <tr id="TRReferringConsultant" runat="server">
                                <td valign="top" class="printFontBasic textalignright">Referring Cons:</td>
                                <td valign="top" class="textalignright">
                                    <asp:Label ID="ReferringConsultantLabel" runat="server" Text="" Font-Bold="true" class="printFontBasic" /></td>
                            </tr>
                            <tr id="TRReferringConsultantName" runat="server">
                                <td valign="top" class="printFontBasic textalignright"></td>
                                <td valign="top" class="textalignright">
                                    <asp:Label ID="ReferringConsultantNameLabel" runat="server" Text="" Font-Bold="true" class="printFontBasic" /></td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td colspan="4" style="height: 30px;"></td>
                </tr>

                <tr>
                    <td colspan="4" valign="top">
                        <table style="width: 100%;">
                            <tr>
                                <td valign="top" width="65%" style="padding-left: 20px;" class="printFontBasic">
                                    <asp:ListView ID="SummaryListView" runat="server" DataSourceID="SummaryObjectDataSource">
                                        <LayoutTemplate>
                                            <table id="itemPlaceholderContainer" runat="server" border="0" cellspacing="0" cellpadding="0" width="100%" class="printFontBasic">
                                                <%--<tr id="alertDiv" runat="server" style="display:none">
                                                    <td style="border-width:1px;border-color:red; width:auto;">
                                                        <div style="padding:5px 15px 5px 15px;text-align: left;"> 
                                                            <img id="AlertImage" runat="server" align="left" style="" /> &nbsp;
                                                            <asp:Literal ID="NpsaAlertLabel" runat="server"/>                                                                                                                
                                                        </div>
                                                    </td>
                                                </tr>--%>
                                                <tr id="itemPlaceholder" runat="server" class="printFontBasic">
                                                </tr>
                                            </table>
                                        </LayoutTemplate>
                                        <ItemTemplate>
                                            <tr>
                                                <td id="NodeNameTD" runat="server" class="printFontBasic">
                                                    <asp:Label ID="NodeNameLabel" runat="server" Text='<%#Eval("NodeName") %>' ForeColor="#0072c6" Font-Bold="true" class="printFontBasic" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td style="padding-left: 5px;" id="NodeSummaryTD" runat="server" class="printFontBasic">
                                                    <asp:Label ID="NodeSummaryLabel" runat="server" Text='<%#Eval("NodeSummary").ToString.Replace("<BR />" + vbCrLf, "<br />").Replace(vbCrLf + vbCrLf, "<br />").Replace(vbCrLf, "<br />")%>' class="printFontBasic" />
                                                </td>
                                            </tr>
                                            <tr style="height: 10px">
                                                <td></td>
                                            </tr>
                                        </ItemTemplate>
                                    </asp:ListView>

                                </td>

                                <td width="2%;"></td>

                                <td valign="top" width="260px">
                                    <table>
                                        <tr>
                                            <td>
                                                <asp:ListView ID="SummaryListViewRightSide" runat="server" DataSourceID="SummaryObjectDataSourceRightSide">
                                                    <LayoutTemplate>
                                                        <table id="itemPlaceholderContainer" runat="server" border="0" class="printFontBasic" cellspacing="0" cellpadding="0" width="100%">
                                                            <tr id="itemPlaceholder" runat="server" class="printFontBasic">
                                                            </tr>
                                                        </table>
                                                    </LayoutTemplate>
                                                    <ItemTemplate>
                                                        <tr>
                                                            <td id="NodeNameTD" runat="server" align="right">
                                                                <asp:Label ID="NodeNameLabel" runat="server" Text='<%#Eval("NodeName") %>' ForeColor="#0072c6" Font-Bold="true" class="printFontBasic" />
                                                                <%--Mahfuz removed font-size="small"--%>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td align="right" id="NodeSummaryTD" runat="server">
                                                                <asp:Label ID="NodeSummaryLabel" runat="server" Text='<%#Eval("NodeSummary") %>' class="printFontBasic" />
                                                            </td>
                                                        </tr>
                                                        <tr style="height: 13px">
                                                            <td></td>
                                                        </tr>
                                                    </ItemTemplate>
                                                </asp:ListView>
                                            </td>
                                        </tr>
                                        <tr runat="server" id="BowelPrepTr" style="display: none">
                                            <td align="right">
                                                <asp:Label runat="server" ID="BowelPrepLabel" class="printFontBasic" /></td>
                                        </tr>
                                        <tr>
                                            <td valign="top" align="right" id="GPReportDiagramSection" runat="server" style="border-style: dashed; border-color: #A4A4A4; border-width: 1px; padding-right: 10px;">
                                                <div id="dsadsada" class="DivDiagramReport" runat="server" clientidmode="Static">
                                                    <div style="float: left;">
                                                        <img id="diagimg" runat="server" src="temp" alt="diagram" class="ImgDiagramReport" style="width: 235px; height: 235px;" />

                                                    </div>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr id="UreaseResultsTr" runat="server" visible="false">
                                            <td>
                                                <table style="margin-top: 5px;">
                                                    <tr>
                                                        <td colspan="4">Urease test results</td>
                                                    </tr>
                                                    <tr>
                                                        <td style="border: 1px solid grey; width: 5px; text-align: center;">
                                                            <asp:Label ID="PositiveResultLabel" runat="server" Text="X" /></td>
                                                        <td>Positive</td>
                                                        <td style="border: 1px solid grey; width: 5px; text-align: center;">
                                                            <asp:Label ID="NegativeResultLabel" runat="server" Text="X" /></td>
                                                        <td>Negative</td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:ListView ID="SummaryListViewAfterDiagram" runat="server" DataSourceID="SummaryObjectDataSourceAfterDiagram">
                                                    <LayoutTemplate>
                                                        <table id="itemPlaceholderContainer" runat="server" border="0" class="printFontBasic" cellspacing="0" cellpadding="0" width="100%">
                                                            <tr id="itemPlaceholder" runat="server">
                                                            </tr>
                                                        </table>
                                                    </LayoutTemplate>
                                                    <ItemTemplate>
                                                        <tr>
                                                            <td id="NodeNameTD" runat="server" align="left">
                                                                <asp:Label ID="NodeNameLabel" runat="server" Text='<%#Eval("NodeName") %>' ForeColor="#0072c6" Font-Bold="true" class="printFontBasic" />
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td align="left" id="NodeSummaryTD" runat="server">
                                                                <asp:Label ID="NodeSummaryLabel" runat="server" Text='<%#Eval("NodeSummary") %>' class="printFontBasic" />
                                                            </td>
                                                        </tr>
                                                        <tr style="height: 10px">
                                                            <td></td>
                                                        </tr>
                                                    </ItemTemplate>
                                                </asp:ListView>
                                            </td>
                                        </tr>
                                    </table>
                                </td>


                            </tr>
                            <tr>
                                <td colspan="2">
                                    <asp:DataList ID="GPPhotosListView" runat="server" DataSourceID="SummaryObjectDataSourcePhotos" RepeatColumns="3" RepeatDirection="Horizontal">
                                        <ItemTemplate>
                                            <br />
                                            <asp:Image ID="GPPhotoImage" runat="server" ImageUrl='<%# Eval("PhotoUrl") %>' Width="100" Height="74" ToolTip='<%# Eval("PhotoUrl") %>' /><br />
                                            <span style="width: 150px">
                                                <asp:Label ID="GPPhotoTitleLabel" runat="server" Text='<%#Eval("PhotoTitle") %>' ForeColor="Black" Width="150px" class="printFontBasic" /></span>
                                            <br />
                                        </ItemTemplate>
                                    </asp:DataList>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </div>


        <%--Photos report--%>
        <div id="PhotosReportDiv" runat="server">
            <table class="mainTable printFontBasic" cellpadding="0" cellspacing="0" style="line-height: 1;">

                <tr>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td>Procedure Date:
                    </td>
                    <td>
                        <asp:Label ID="ProcedureDateLabel2" runat="server" Text="" Font-Bold="true" /></td>
                </tr>
                <tr>
                    <td colspan="5">
                        <asp:DataList ID="PhotosListView" runat="server" DataSourceID="SummaryObjectDataSourcePhotos" RepeatColumns="1" RepeatDirection="Horizontal" CellSpacing="10">
                            <ItemTemplate>
                                <br />
                                <asp:Image ID="PhotoImage" runat="server" ImageUrl='<%# Eval("PhotoUrl") %>' ToolTip='<%# Eval("PhotoUrl") %>' class="PhotoImageWidth" />&nbsp;&nbsp;<br />
                                <asp:Label ID="PhotoTitleLabel" runat="server" Text='<%#Eval("PhotoTitle") %>' ForeColor="Black" class="printFontBasic" />
                                <br />
                            </ItemTemplate>
                        </asp:DataList>
                    </td>
                </tr>
            </table>
        </div>

        <%--Patient Friendly Report--%>
        <div id="PatientCopyReportDiv" runat="server" style="width: 100%; padding-left: 20px;">
            <table class="mainTable printFontBasic" cellpadding="0" cellspacing="0" style="line-height: 1; width: 100%;">
                <tr>
                    <td colspan="5" style="height: 30px; font-size: larger; font-weight: 700;" align="center">Patient Report</td>
                </tr>
                <tr>
                    <td colspan="5" style="height: 30px"></td>
                </tr>
                <tr>
                    <td style="font-weight: bold;">Procedure:</td>
                    <td colspan="4">
                        <asp:Label ID="FRProcedureLabel" runat="server" Text="" /></td>
                </tr>
                <tr>
                    <td colspan="5" style="height: 15px"></td>
                </tr>
                <tr>
                    <td style="font-weight: bold;">Procedure Date:</td>
                    <td colspan="4">
                        <asp:Label ID="ProcedureDateLabel3" runat="server" Text="" /></td>

                </tr>
                <tr>
                    <td colspan="5" style="height: 15px"></td>
                </tr>
                <tr>
                    <td style="font-weight: bold;">Procedure Completed:</td>
                    <td colspan="4">
                        <asp:Label ID="FRProcedureCompleted" runat="server" Text="" /></td>
                </tr>
                <tr>
                    <td colspan="5" style="height: 15px"></td>
                </tr>
                <tr>
                    <td valign="top" style="font-weight: bold;width:20%;">Medication:</td>
                    <td colspan="4" >
                        <asp:Label ID="FRMedication" runat="server" Text="" /></td>
                </tr>
                <tr>
                    <td colspan="5" style="height: 15px"></td>
                </tr>
                <tr>
                    <td style="font-weight: bold;">Results:</td>
                </tr>
                <tr>
                    <td colspan="5" style="height: 15px"></td>
                </tr>
                <tr>
                    <td colspan="5">
                        <asp:ListView ID="ResultListView" runat="server">
                            <LayoutTemplate>
                                <table id="resultPlaceholderContainer" runat="server" border="0" class="printFontBasic" cellspacing="3" cellpadding="0" width="100%">
                                    <tr id="itemPlaceholder" runat="server">
                                    </tr>
                                </table>
                            </LayoutTemplate>
                            <ItemTemplate>
                                <tr>
                                    <td valign="bottom">
                                        <asp:Label ID="PatientFriendlyResultLabel" runat="server" Text='<%# Eval("result") %>' class="printFontBasic" />
                                    </td>
                                    <td style="width: 25px;"></td>
                                </tr>
                                <tr>
                                    <td style="height: 10px;"></td>
                                </tr>
                            </ItemTemplate>
                        </asp:ListView>
                    </td>
                </tr>
                <%--<tr runat="server" id="result_1" visible="false">
                    <td runat="server" id="UreaseTextID" colspan="5"><strong>&#8226;</strong>&nbsp;&nbsp;You have had little bits taken out of you called biopsies, these have been taken to see if you have a bug in your tummy known as helicobactor pylori, which can make you feel poorly. The results will be given to your GP in 2-3 working days.
                    </td>
                </tr>
                <tr runat="server" id="space_1" visible="false" >
                    <td colspan="5" style="height: 15px"></td>
                </tr>
                <tr runat="server" id="result_2" visible="false">
                    <td runat="server" id="PolypectomyTextID" colspan="5"><strong>&#8226;</strong>&nbsp;&nbsp;One or more polyps have been removed today. The doctor who requested this test will receive the results and will arrange for these results to be communicated to you, either by writing to you and your GP. or alternatively by seeing you in a clinic or telephone clinic.
                    </td>
                </tr>
                <tr runat="server" id="space_2" visible="false" >
                    <td colspan="5" style="height: 15px"></td>
                </tr>
                <tr runat="server" id="result_3" visible="false">
                    <td runat="server" id="OtherBiopsyTextID" colspan="5"><strong>&#8226;</strong>&nbsp;&nbsp;A number of biopsies have been taken during the test. Biopsies are taken routinely in the majority of patients. These results will be communicated to you, either by writing to you and your GP, or alternatively by seeing you in a clinic or telephone clinic.
                    </td>
                </tr>
                <tr runat="server" id="space_3" visible="false" >
                    <td colspan="5" style="height: 15px"></td>
                </tr>
                <tr runat="server" id="result_4" visible="false">
                    <td runat="server" id="IncludeAnyOtherBiopsyText" colspan="5"><strong>&#8226;</strong>&nbsp;&nbsp;Results will be sent to your consultant, who will let your GP know in 4-10 working days.<br />
                    </td>
                </tr>--%>
                <tr>
                    <td colspan="5" style="height: 5px"></td>
                </tr>
                <tr>
                    <td style="font-weight: bold;">Follow-Up:</td>
                    <td colspan="4">
                        <asp:Label ID="FRFollowUp" runat="server" Text="" /></td>
                </tr>
                <tr>
                    <td colspan="5" style="height: 15px"></td>
                </tr>
                <tr>
                    <td colspan="5">
                        <table width="100%" class="printFontBasic">
                            <tr>
                                <td colspan="4" style="width: 60%;">Clinical:<asp:Label ID="Label1" runat="server" Text="<b>_____________________________</b>" /><br />
                                    <br />
                                    Date & Time of appointment:<asp:Label ID="Label3" runat="server" Text="<b>___________________/_______________</b>" />
                                </td>
                                <td colspan="3" style="width: 40%;">
                                    <table class="printFontBasic">
                                        <tr>
                                            <%--<td class="tickbox" style="width: 20px !important; text-align: right;"></td>--%>
                                            <td align="right">
                                                <img id="NoFutherFollowupImg" src="/Images/Rectangle.png" alt="Rectangle" style="width: 20px;" runat="server" />
                                                <img id="NoFutherFollowupImgChecked" src="/Images/CheckedRectangle.png" alt="RectangleChecked" style="width: 20px;" runat="server" visible="false" />
                                            </td>
                                            <td>&nbsp;&nbsp;&nbsp;No futher followup or procedure required</td>
                                        </tr>
                                        <tr>
                                            <td colspan="3" style="height: 15px"></td>
                                        </tr>
                                        <tr>
                                            <%--<td class="tickbox" style="width: 20px !important; text-align: right;"></td>--%>
                                            <td align="right">
                                                <img id="FollowInThePostImg" src="/Images/Rectangle.png" alt="Rectangle" style="width: 20px;" runat="server" />
                                                <img id="FollowInThePostImgChecked" src="/Images/CheckedRectangle.png" alt="RectangleChecked" style="width: 20px;" runat="server" visible="false" />
                                            </td>
                                            <td>&nbsp;&nbsp;&nbsp;Follow up to follow in the post</td>
                                        </tr>
                                        <tr>
                                            <td colspan="3" style="height: 15px"></td>
                                        </tr>
                                        <tr>
                                            <%--<td class="tickbox DischargeToGp" style="text-align: right;"></td>--%>
                                            <td align="right">
                                                <img id="DischargeToGpImg" style="width: 20px;" src="/Images/Rectangle.png" alt="Rectangle" runat="server" />
                                                <img id="DischargeToGpImgChecked" style="width: 20px;" src="/Images/CheckedRectangle.png" alt="RectangleChecked" runat="server" visible="false" />
                                            </td>
                                            <td>&nbsp;&nbsp;&nbsp;Discharge to GP</td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <%-- <tr>
                                <td colspan="7" style="height: 15px"></td>
                            </tr>
                            <tr>
                                <td colspan="4" valign="top">Date & Time of appointment:
                                    <asp:Label ID="Label2" runat="server" Text="<b>___________________/_______________</b>" />
                                </td>
                                <td colspan="3">
                                    <table class="printFontBasic">
                                        <tr>
                                            <td class="tickbox DischargeToGp" style="text-align: right;"></td>
                                            <td>&nbsp;&nbsp;&nbsp;Discharge to GP</td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>--%>
                        </table>
                    </td>
                    <%-- <td colspan="1">
                        <table width="100%">
                            <tr>
                                <td class="tickbox"></td>
                                <td style="width: 10px;"></td>
                                <td>Follow up to follow in the post</td>
                            </tr>
                            <tr>
                                <td style="height: 15px"></td>
                            </tr>
                            <tr>
                                <td class="tickbox"></td>
                                 <td style="width: 10px;"></td>
                                <td>Discharge to GP</td>
                            </tr>
                        </table>
                    </td>--%>
                </tr>

                <tr>
                    <td colspan="5" style="height: 15px"></td>
                </tr>
                <tr>
                    <td colspan="5">
                        <table width="100%">
                            <%--<tr id="PRNoFollowUp" runat="server">
                                <td colspan="3" valign="bottom">
                                    <br />
                                    <asp:Label ID="PRNoFollowUpLabel" runat="server" Text="No further follow up appointment is necessary" class="printFontBasic" />
                                    <br />
                                    <br />
                                </td>
                            </tr>
                            <tr id="PRUrease" runat="server">
                                <td colspan="3" valign="bottom">
                                    <br />
                                    <asp:Label ID="PRUreaseLabel" runat="server" class="printFontBasic" />
                                    <br />
                                    <br />
                                </td>
                            </tr>
                            <tr id="PRPolypectomy" runat="server">
                                <td colspan="3" valign="bottom">
                                    <br />
                                    <asp:Label ID="PRPolypectomyLabel" runat="server" class="printFontBasic" />
                                    <br />
                                    <br />
                                </td>
                            </tr>
                            <tr id="PRBiopsy" runat="server">
                                <td colspan="3" valign="bottom">
                                    <br />
                                    <asp:Label ID="PRBiopsyLabel" runat="server" class="printFontBasic" />
                                    <br />
                                    <br />
                                </td>
                            </tr>
                            <tr>
                                <td style="height: 20px;"></td>
                            </tr>
                            <tr id="PRAdviceComments" runat="server">
                                <td colspan="3" valign="bottom">
                                    <br />
                                    <asp:Label ID="PRAdviceCommentsLabel" runat="server" class="printFontBasic" />
                                    <br />
                                    <br />
                                </td>
                            </tr>
                            <tr>
                                <td style="height: 20px;"></td>
                            </tr>--%>
                            <tr id="FinalTextSection" runat="server">
                                <td valign="bottom">
                                    <br />
                                    <asp:Label ID="FinalTextLabel" runat="server" class="printFontBasic" />
                                    <br />
                                    <br />
                                </td>
                                <td style="width: 25px;"></td>
                            </tr>
                            <tr>

                                <td colspan="3" valign="bottom" class="printFontBasic">
                                    <br />
                                    <br />
                                    Signature .................................................
                                </td>
                            </tr>
                            <tr>
                                <td colspan="5" style="height: 15px"></td>
                            </tr>
                            <tr>

                                <td colspan="3" valign="bottom" class="printFontBasic">Name and Designation ...............................................................
                                    <br />
                                    <br />
                                    <br />
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td colspan="5" style="height: 15px"></td>
                </tr>
                <tr>
                    <td colspan="5">
                        <asp:ListView ID="PatientFriendlyTextListView" runat="server">
                            <LayoutTemplate>
                                <table id="itemPlaceholderContainer" runat="server" border="0" class="printFontBasic" cellspacing="3" cellpadding="0" style="width: 100%;">
                                    <tr id="itemPlaceholder" runat="server">
                                    </tr>
                                </table>
                            </LayoutTemplate>
                            <ItemTemplate>
                                <tr>
                                    <td style="width:20px !important;">
                                        <img src="/Images/Rectangle.png" alt="Rectangle" style="width: 20px;" />
                                    </td>
                                    <%--<td class="tickbox" style="width: 20px !important;"></td>--%>
                                    <td style="width: 10px;"></td>
                                    <td>
                                        <asp:Label ID="PatientFriendlyTextLabel" runat="server" Text='<%#Container.DataItem.ToString() %>' class="printFontBasic" />
                                    </td>
                                </tr>
                                <tr>
                                    <td style="height: 10px;"></td>
                                </tr>
                            </ItemTemplate>
                        </asp:ListView>
                    </td>
                </tr>
            </table>
        </div>


        <%--Lab Request report--%>
        <div id="LabRequestDiv" runat="server" style="width: 100%;">
            <table class="LabRequestFormTable printFontBasic" cellpadding="0" cellspacing="5" style="line-height: 1;">
                <thead>
                    <tr>
                        <td width="20%" class="LabRequestTableBorder" valign="top">
                            <table>
                                <tr>
                                    <td class="LabRequestFormLabelHeader">
                                        <asp:Label ID="lblLabRequestCaseNoteNo" runat="server" Text="Hospital no" />
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding-left: 10px;">
                                        <asp:Label ID="CaseNoteNoLabel4" runat="server" Text="" CssClass="LabRequestFormLabelData" />
                                    </td>
                                </tr>
                                <tr>
                                    <td class="LabRequestFormLabelHeader">
                                        <asp:Label ID="lblLabRequestNHSNo" runat="server" Text="<%=Session(Constants.SESSION_HEALTH_SERVICE_NAME).ToString() %> No" />
                                    </td>
                                </tr>
                                <tr>
                                    <td style="padding-left: 10px;">
                                        <asp:Label ID="NhsNoLabel4" runat="server" Text="" CssClass="LabRequestFormLabelData" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td width="60%">
                            <table>
                                <tr>
                                    <td align="center">Request for examination</td>
                                </tr>
                                <tr>
                                    <td align="center">
                                        <asp:Label ID="LabRequestHeader" runat="server" Text="LAB REQUEST FORM" CssClass="LabRequestHeader" />
                                    </td>
                                </tr>
                                <tr id="TRLabReferringHospital" runat="server">
                                    <td align="center">
                                        <asp:Label ID="HospitalLabel4" runat="server" Text="" CssClass="LabRequestFormLabelData" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td width="20%" class="LabRequestTableBorder" valign="top">
                            <table id="DateTimeCollectedSection" runat="server">
                                <tr>
                                    <td colspan="2" class="LabRequestFormLabelHeader">Date/Time Collected</td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <asp:Label ID="ProcedureDateLabel4" runat="server" Text="" CssClass="LabRequestFormLabelData" />
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" style="background-color: lightgrey;" class="LabRequestFormLabelData">Laboratory Number</td>
                                </tr>
                                <tr>
                                    <td colspan="2" class="LabRequestFormLabelData">This request is;</td>
                                </tr>
                                <tr>
                                    <td colspan="2" class="LabRequestFormLabelHeader">Urgent pathway;</td>
                                </tr>
                                <tr>
                                    <td colspan="2" class="LabRequestFormLabelHeader">Routine;</td>
                                </tr>
                                <tr>
                                    <td colspan="2" class="LabRequestFormLabelHeader">Urgent;</td>
                                </tr>
                                <tr>
                                    <td colspan="2" class="LabRequestFormLabelHeader">2 WW;</td>
                                </tr>
                                <tr>
                                    <td colspan="2" style="background-color: lightgrey;" class="LabRequestFormLabelData">Patient Category</td>
                                </tr>
                                <tr>
                                    <td class="LabRequestFormLabelHeader"><%=HttpContext.Current.Session("CountryOfOriginHealthService").ToString().ToUpper() %> or PP</td>
                                    <td class="LabRequestFormLabelHeader">IP or OP or DC</td>
                                </tr>

                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="3">
                            <table id="Table1" runat="server" class="mainTable" cellpadding="0" cellspacing="0" style="line-height: 1;">
                                <tr>
                                    <td colspan="5">
                                        <hr style="height: 0.2px; color: black;" />
                                    </td>
                                </tr>
                                <tr>
                                    <td width="20%" class="printFontBasic">Name:</td>
                                    <td width="35%">
                                        <asp:Label ID="ForenameLabel" runat="server" Text="" Font-Bold="true" class="printFontBasic" />&nbsp;<asp:Label ID="SurnameLabel" runat="server" Text="" Font-Bold="true" class="printFontBasic" />
                                    </td>
                                    <td width="5%" />
                                    <td width="15%" class="printFontBasic">Address:</td>
                                    <td rowspan="6" valign="top" width="25%">
                                        <asp:Label ID="AddressLabel4" runat="server" Text="" Font-Bold="true" class="printFontBasic" />
                                    </td>
                                </tr>
                                <tr>
                                    <td class="printFontBasic">Date of birth (age):</td>
                                    <td>
                                        <asp:Label ID="DOBAgeLabel" runat="server" Text="" Font-Bold="true" class="printFontBasic" />
                                    </td>
                                    <td />
                                    <td />
                                </tr>
                                <tr>
                                    <td class="printFontBasic">Gender:</td>
                                    <td>
                                        <asp:Label ID="GenderLabel" runat="server" Text="" Font-Bold="true" class="printFontBasic" />
                                    </td>
                                    <td />
                                    <td />
                                </tr>
                                <tr>
                                    <td />
                                    <td>
                                        <asp:Label ID="PatientStatusWardLabel" runat="server" Text="" Font-Bold="true" class="printFontBasic" />
                                    </td>
                                    <td />
                                    <td />
                                </tr>
                                <tr id="TRLabReferringConsultant" runat="server">
                                    <td class="printFontBasic">Referring Consultant:</td>
                                    <td>
                                        <asp:Label ID="ReferringConsultantLabel4" runat="server" Text="" Font-Bold="true" class="printFontBasic" />
                                    </td>
                                    <td />
                                    <td />
                                </tr>
                                <tr>
                                    <td valign="top" class="printFontBasic">GP Practice:</td>
                                    <%--Added by rony 3565--%>
                                    <td>
                                        <asp:Label ID="GPAddressLabel4" runat="server" Text="" Font-Bold="true" class="printFontBasic" />
                                    </td>
                                    <td />
                                    <td />
                                </tr>
                                <tr>
                                    <td colspan="5">
                                        <hr style="height: 0.2px; color: black;" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td colspan="3" valign="top" class="LabRequestTableBorder">
                            <table width="100%">
                                <tr>
                                    <td width="60%" valign="top" style="padding: 5px;">
                                        <table width="100%">
                                            <tr>
                                                <td class="LabRequestFormLabelHeader">Investigations Required
                                                <asp:ListView ID="LabRequestSpecimenListView" runat="server" DataSourceID="SummaryObjectDataSourceSpecimens" DataKeyNames="SpecimenKey,Specimen">
                                                    <LayoutTemplate>
                                                        <table id="itemPlaceholderContainer" runat="server" border="0"
                                                            cellspacing="5" cellpadding="0" width="100%">
                                                            <tr>
                                                                <td width="20%" class="LabRequestFormLabelHeader">Container ID
                                                                </td>
                                                                <td width="80%" class="LabRequestFormLabelHeader">Specimens
                                                                </td>
                                                            </tr>
                                                            <tr id="itemPlaceholder" runat="server">
                                                            </tr>
                                                        </table>
                                                    </LayoutTemplate>
                                                    <ItemTemplate>
                                                        <tr id="specimensTR" runat="server">
                                                            <td id="LabRequestSpecimenContainerIdSection" runat="server">
                                                                <div class="tickboxLabRequestForm">
                                                                </div>
                                                            </td>
                                                            <td style="padding-left: 5px;" id="NodeSummaryTD" runat="server">
                                                                <asp:Label ID="SpecimenTextLabel" runat="server" Text='<%#Eval("Specimen") %>' CssClass="labRequestSpecimenTextInactive" />
                                                            </td>
                                                        </tr>
                                                    </ItemTemplate>
                                                </asp:ListView>
                                                </td>
                                            </tr>
                                            <tr style="height: 20px;">
                                                <td></td>
                                            </tr>
                                            <tr>
                                                <td id="LabRequestIndicationsHeadingSection" runat="server" class="LabRequestFormLabelHeader">
                                                    <asp:Label ID="LabRequestIndicationsHeadingLabel" runat="server" Text="Clinical findings" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td valign="top">
                                                    <asp:ListView ID="SummaryListView4" runat="server" DataSourceID="SummaryObjectDataSource">
                                                        <LayoutTemplate>
                                                            <table id="itemPlaceholderContainer" runat="server" border="0" class="printFontBasic" cellspacing="0" cellpadding="0" width="100%">
                                                                <tr id="itemPlaceholder" runat="server">
                                                                </tr>
                                                            </table>
                                                        </LayoutTemplate>
                                                        <ItemTemplate>
                                                            <tr>
                                                                <td id="NodeNameTD" runat="server">
                                                                    <asp:Label ID="NodeNameLabel" runat="server" Text='<%#Eval("NodeName") %>' ForeColor="#0072c6" Font-Bold="true" class="printFontBasic" />
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td id="NodeSummaryTD" runat="server">
                                                                    <asp:Label ID="NodeSummaryLabel" runat="server" Text='<%#Eval("NodeSummary") %>' class="printFontBasic" />
                                                                </td>
                                                            </tr>
                                                            <tr style="height: 10px">
                                                                <td></td>
                                                            </tr>
                                                        </ItemTemplate>
                                                    </asp:ListView>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                    <td width="40%" valign="top" align="right" style="padding: 5px;" id="LabRequestDiagramSection" runat="server">
                                        <img id="diagimg4" runat="server" src="temp" alt="diagram" class="LabRequestImgDiagramReport" />
                                        <br />
                                        <asp:Label ID="SiteLegendLabel" runat="server" Text="" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="3" class="LabRequestTableBorder">
                            <table width="100%">
                                <tr>
                                    <td valign="top" class="LabRequestFormLabelHeader">Previous biopsy numbers</td>
                                </tr>
                                <tr>
                                    <td style="height: 40px;" />
                                </tr>
                                <tr>
                                    <td valign="top" style="border-bottom: 1px solid black;" class="LabRequestFormLabelHeader">For Lab Use</td>
                                </tr>
                                <tr>
                                    <td style="height: 40px;" />
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td class="LabRequestTableBorder">
                            <div style="vertical-align: top; height: 25px" class="LabRequestFormLabelHeader">Date/time rec'd</div>
                            <div style="vertical-align: top; height: 25px" class="LabRequestFormLabelHeader">Date Reported</div>
                        </td>
                        <td colspan="2" class="LabRequestTableBorder" valign="top">COPY TO</td>
                    </tr>
                </tbody>

            </table>
        </div>
        <div>
        </div>
    </form>
</body>
</html>
