<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/Templates/Reports.Master"
    CodeBehind="ListAnalysisMain.aspx.vb" Inherits="UnisoftERS.ListAnalysisMain"
    ValidateRequest="False" %>

<asp:Content ID="MainBodyContent" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <script type="text/javascript" src="../../Scripts/Reports.js"></script>
    <telerik:RadSkinManager ID="RadSkinManager1" runat="server" Skin="Office2010Blue" />
    <%--<telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All"
        DecorationZoneID="ContentDiv" Skin="Metro" />
    --%><telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Width="500px" Height="200px"
        Skin="Metro" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
        ForeColor="Red" Position="Center" />

    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" Modal="true" Width="100%">
    </telerik:RadAjaxLoadingPanel>

    <div id="loaderPreview">
        Loading...
    </div>

    <div id="Content">

        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0"
            PanesBorderSize="0">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Height="100%">
                <asp:Panel ID="NoProceduresPanel" runat="server" Visible="false">
                </asp:Panel>
                <asp:Panel ID="ReportPanel" runat="server">
                    <div style="margin: 0px 10px; width: 95%;">
                        <div style="margin-top: 10px;"></div>
                        <telerik:RadTabStrip ID="RadTabStrip1" runat="server" MultiPageID="RadMultiPage1"
                            SelectedIndex="0" Skin="Metro" RenderMode="Lightweight" Font-Size="Larger">
                            <Tabs>
                                <telerik:RadTab Text="Filter" Value="1" Font-Bold="false" Selected="true" PageViewID="RadPageView1"
                                    Width="80" Style="text-align: center;" />
                                <telerik:RadTab Text="Preview" Value="2" Font-Bold="false" PageViewID="RadPageView2"
                                    Selected="false" Enabled="true" />
                            </Tabs>
                        </telerik:RadTabStrip>
                        <telerik:RadMultiPage ID="RadMultiPage1" runat="server" Height="100%">
                            <telerik:RadPageView ID="RadPageView1" runat="server" Selected="true" Height="100%">
                                <div style="display:flex;flex-direction:row;height:100%">
                                    <div style="display:flex;flex-direction:column; width:327px">
                                        <div style="display:flex;flex-direction:row; width:100%">
                                            <div style="display:flex;flex-direction:column;border: 1px solid #c2d2e2; width:100%; margin:5px;">
                                                <div class="filterRepHeader collapsible_header">
                                                    <img src="../../Images/icons/collapse-arrow-down.png" alt="" />
                                                    <span style="padding-left: 5px;">Operating hospital</span>
                                                </div>
                                                <div id="Div1" runat="server" class="content" style="padding: 15px;">
                                                    <telerik:RadComboBox CheckBoxes="true" EnableCheckAllItemsCheckBox="true" CheckedItemsTexts="DisplayAllInInput"
                                                        ID="OperatingHospitalsRadComboBox" OnItemDataBound="OperatingHospitalsRadComboBox_ItemDataBound"
                                                        runat="server" Width="287px" AutoPostBack="true" />
                                                </div>
                                            </div>
                                        </div>
                                        <div style="display:flex;flex-direction:row; width:100%">
                                            <div style="display:flex;flex-direction:column;border: 1px solid #c2d2e2; width:100%; margin:5px;">
                                                <div class="filterRepHeader collapsible_header">
                                                    <img src="../../Images/icons/collapse-arrow-down.png" alt="" />
                                                    <span style="padding-left: 5px;">Consultant</span>
                                                </div>
                                                <div id="Div2" runat="server" class="content" style="padding: 15px; padding-bottom: 21px;">
                                                    <telerik:RadListBox ID="RadListBox1" runat="server" Width="287px" Height="210px"
                                                    Skin="Silk"
                                                    CheckBoxes="true" ShowCheckAll="true"
                                                    SelectionMode="Multiple" DataSourceID="SqlDSAllConsultants" DataKeyField="UserID"
                                                    DataTextField="Consultant"
                                                    DataValueField="UserID">
                                                    </telerik:RadListBox>
                                                    <telerik:RadTextBox runat="server" ID="ISMFilter" CssClass="consultant-search" Width="160px" Visible="false"
                                                        EmptyMessage="Consultant name" Skin="Windows7">
                                                    </telerik:RadTextBox>
                                                <asp:ObjectDataSource ID="SqlDSAllConsultants" runat="server" SelectMethod="GetConsultantsListBox1"
                                                    TypeName="UnisoftERS.Reporting">
                                                    <SelectParameters>
                                                         <asp:Parameter DefaultValue="list,endoscopist1,endoscopist2,"  Name="consultantTypeName" DbType="String"  />
                                                        <asp:ControlParameter Name="searchPhrase" DbType="String" ControlID="ISMFilter" ConvertEmptyStringToNull="true" />
                                                        <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                                                         <asp:SessionParameter DefaultValue="0" Name="operatingHospitalsIds" SessionField="OperatingHospitalIdsForTrust" Type="String" />
                                                            <asp:Parameter Name="HideSuppressed" DbType="Boolean"  DefaultValue="false" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>
                                                <asp:ObjectDataSource ID="SqlDSSelectedConsultants" runat="server" SelectMethod="GetConsultantsListBox2"
                                                    TypeName="UnisoftERS.Reporting">
                                                    <SelectParameters>
                                                        <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>


                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div style="display:flex;flex-direction:column; width:650px;">
                                        <div style="display:flex;flex-direction:row; width:100%">
                                            <div style="display:flex;flex-direction:column;border: 1px solid #c2d2e2; width:100%; margin:5px;">

                                                <div class="filterRepHeader collapsible_header">
                                                    <img src="../../Images/icons/collapse-arrow-down.png" alt="" />
                                                    <span style="padding-left: 5px;">Dates</span>
                                                </div>
                                                <div class="content" style="padding: 7px;">
                                                    From:&nbsp;
                                                    <telerik:RadDatePicker ID="RDPFrom" runat="server" Width="150px" Skin="Windows7" RenderMode="classic" />
                                                    &nbsp;To: &nbsp;
                                                    <telerik:RadDatePicker ID="RDPTo" runat="server" Width="150px" Skin="Windows7" />
                                                    <br />
                                                    <asp:HiddenField ID="SUID" runat="server" />
                                                    <asp:RequiredFieldValidator runat="server" ID="RequiredFieldValidatorFromDate" ControlToValidate="RDPFrom"
                                                        ErrorMessage="Enter a date!" SetFocusOnError="True" ValidationGroup="FilterGroup"
                                                        ForeColor="Red"></asp:RequiredFieldValidator>
                                                    <asp:RequiredFieldValidator runat="server" ID="RequiredfieldvalidatorToDate" ControlToValidate="RDPTo"
                                                        ErrorMessage="Enter a date!" ValidationGroup="FilterGroup" ForeColor="Red"></asp:RequiredFieldValidator>
                                                    <asp:CompareValidator ID="dateCompareValidator" runat="server" ControlToValidate="RDPTo"
                                                        ControlToCompare="RDPFrom" Operator="GreaterThan" ValidationGroup="FilterGroup"
                                                        Type="Date" ErrorMessage="End date must be after the start date." SetFocusOnError="True"
                                                        ForeColor="Red"></asp:CompareValidator>
                                                </div>
                                            </div>
                                        </div>
                                        <div style="display:flex;flex-direction:row; width:100%">
                                            <div style="display:flex;flex-direction:column;border: 1px solid #c2d2e2; width:100%; margin:5px;">
                                                <div class="filterRepHeader collapsible_header">
                                                    <img src="../../Images/icons/collapse-arrow-down.png" alt="" />
                                                    <span style="padding-left: 5px;">Report order</span>
                                                </div>
                                                <div class="content" style="padding: 10px;">
                                                    <asp:RadioButtonList ID="DateOrderRadioButton" runat="server" AutoPostBack="false"
                                                        CssClass="" RepeatDirection="Horizontal">
                                                        <asp:ListItem Value="DESC">Date descending (most recent to oldest)</asp:ListItem>
                                                        <asp:ListItem Selected="True" Value="ASC">Date ascending (oldest to most recent)</asp:ListItem>
                                                    </asp:RadioButtonList>
                                                </div>

                                            </div>
                                        </div>                                    

                                        <div style="display:flex;flex-direction:row; width:100%">
                                            <div style="display:flex;flex-direction:column;border: 1px solid #c2d2e2; width:100%; margin:5px;">
                                                <div class="filterRepHeader collapsible_header">
                                                    <img src="../../Images/icons/collapse-arrow-down.png" alt="" />
                                                    <span style="padding-left: 5px;">Patient status</span>
                                                </div>
                                                <div class="content" style="padding: 10px;">

                                                    <asp:RadioButtonList ID="PatientStatusRadioButton" runat="server" AutoPostBack="false"
                                                        CssClass="grsrep" RepeatDirection="Horizontal">
                                                        <asp:ListItem Selected="True" Value="0">All</asp:ListItem>
                                                        <asp:ListItem Value="1">Inpatient</asp:ListItem>
                                                        <asp:ListItem Value="2">Outpatient</asp:ListItem>
                                                        <asp:ListItem Value="3">Day&#160;patient</asp:ListItem>
                                                    </asp:RadioButtonList>
                                                    <asp:RadioButtonList ID="NhsVsPrivateRadioButton" runat="server" AutoPostBack="false"
                                                        CssClass="grsrep" RepeatDirection="Horizontal">
                                                        <asp:ListItem Selected="True" Value="0">All</asp:ListItem>
                                                        <asp:ListItem Value="1">NHS</asp:ListItem>
                                                        <asp:ListItem Value="2">Private</asp:ListItem>
                                                    </asp:RadioButtonList>


                                                </div>
                                            </div>
                                        </div>     
                                    

                                        <div style="display:flex;flex-direction:row; width:100%">
                                            <div style="display:flex;flex-direction:column;border: 1px solid #c2d2e2; width:100%; margin:5px;">
                                                <div class="filterRepHeader collapsible_header">
                                                    <img src="../../Images/icons/collapse-arrow-down.png" alt="" />
                                                    <span style="padding-left: 5px;">Reports</span>
                                                </div>
                                                <div id="Div3" runat="server" class="content" style="padding: 15px; padding-bottom: 21px;">
                                                    <table>
                                                        <tr>
                                                            <td style="vertical-align:top">
                                                                <asp:CheckBox runat="server" id="chkListPatients" Text="list of patients" Width="250px" onClick="showHidepatientOptions()" />
                                                                <div id="patientOptions" runat="server" style="padding-left:10px;">
                                                                    <asp:CheckBox runat="server" ID="chkPatientAnon" Text="anonymised" /><br />
                                                                    <asp:CheckBox runat="server" ID="chkPatientTherapeutics" Text="include therapeutics" /><br />
                                                                    <asp:CheckBox runat="server" ID="chkPatientIndications" Text="include indications" />
                                                                </div>
                                                            </td>
                                                            <td style="vertical-align:top">
                                                                <asp:CheckBox runat="server" ID="chkSummaryForPeriod" Text="summary for the period" Width="250px" onClick="showHideSummaryOptions()" />
                                                                <div id="summaryOptions" runat="server" style="padding-left:10px;">
                                                                    <asp:CheckBox runat="server" ID="chkSummaryDiagThera" Text="diagnostic vs therapeutic" />
                                                                    <br />
                                                                    <asp:RadioButtonList runat="server" ID="optEndoscopistConsultant" >
                                                                        <asp:ListItem Value="0" Text="Report for endoscopist" Selected="True" />
                                                                        <asp:ListItem Value="1" Text="Report for list consultant" />
                                                                    </asp:RadioButtonList>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </div>
                                            </div>
                                        </div>    
                                    </div>
                                </div>
                                <div style="display:flex;flex-direction:row">
                                    <div style="display:flex;flex-direction:column; border: 1px solid #c2d2e2; margin:5px; width:965px">

                                    </div>
                                </div>
                                <div style="margin-top: 10px;">
                                    <telerik:RadButton ID="RadButtonFilter" runat="server" Text="Apply filter" Skin="Silk"
                                        ValidationGroup="FilterGroup" OnClientClicking="ValidatingForm" ButtonType="SkinnedButton"
                                        SkinID="RadSkinManager1" Icon-PrimaryIconUrl="~/Images/icons/filter.png">
                                    </telerik:RadButton>
                                </div>
                            </telerik:RadPageView>


                            <telerik:RadPageView ID="RadPageView2" runat="server">

                                <div style="padding-left: 20px; padding-right: 20px; padding-bottom: 50px; height: 550px" class="ConfigureBg">

                                        <telerik:RadTabStrip ID="RadTabStrip2" runat="server" MultiPageID="RadMultiPage2" SelectedIndex="0" Skin="Office2010Silver" RenderMode="Lightweight">
                                        <Tabs>
                                            <telerik:RadTab runat="server" Text="List patient" Selected="True">
                                            </telerik:RadTab>
                                            <telerik:RadTab runat="server" Text="Summary for period">
                                            </telerik:RadTab>
                                        </Tabs>
                                    </telerik:RadTabStrip>
                                    <telerik:RadMultiPage ID="RadMultiPage2" runat="server" SelectedIndex="0">
                                        <telerik:RadPageView ID="RadPageListPatient" runat="server">
                                            <telerik:RadGrid ID="RadGridListPatients" runat="server" Skin="Office2010Blue" OnNeedDataSource="RadGridListPatients_NeedDataSource">
                                                <ClientSettings Scrolling-AllowScroll="true" Scrolling-UseStaticHeaders="true" ></ClientSettings>
                                                <ExportSettings Excel-Format="Html" ExportOnlyData="true" IgnorePaging="true" ></ExportSettings>
                                                <MasterTableView CommandItemDisplay="Top" CommandItemStyle-Font-Bold="true">
                                                    <CommandItemSettings ShowExportToExcelButton="true" ExportToExcelText="Export" ShowAddNewRecordButton="false" ShowRefreshButton="false" />
                                                </MasterTableView>                                            </telerik:RadGrid>
                                        </telerik:RadPageView>
                                        <telerik:RadPageView ID="RadPageSummary" runat="server">
                                            <telerik:RadGrid ID="RadGridSummary" runat="server" Skin="Office2010Blue" OnNeedDataSource="RadGridSummary_NeedDataSource">
                                                <ClientSettings Scrolling-AllowScroll="true" Scrolling-UseStaticHeaders="true" ></ClientSettings>
                                                <ExportSettings Excel-Format="Html" ExportOnlyData="true" IgnorePaging="true" ></ExportSettings>
                                                <MasterTableView CommandItemDisplay="Top" CommandItemStyle-Font-Bold="true">
                                                    <CommandItemSettings ShowExportToExcelButton="true" ExportToExcelText="Export" ShowAddNewRecordButton="false" ShowRefreshButton="false" />
                                                </MasterTableView>
                                            </telerik:RadGrid>
                                        </telerik:RadPageView>
                                    </telerik:RadMultiPage>
                                </div>
                            </telerik:RadPageView>
                        </telerik:RadMultiPage>
                    </div>
                </asp:Panel>
            </telerik:RadPane>
        </telerik:RadSplitter>
    </div>

    <telerik:RadScriptBlock runat="server">

        <script type="text/javascript" src="../../Scripts/Reports.js"></script>
        <script type="text/javascript">


            var docURL = document.URL;
            var grid;
            var ListAnalysis1 = {}
            ListAnalysis1.columnName = "";
            ListAnalysis1.rowID = "";
            var ListAnalysis2 = {}
            ListAnalysis2.columnName = "";
            ListAnalysis2.rowID = "";
            var ListAnalysis3 = {}
            ListAnalysis3.columnName = "";
            ListAnalysis3.rowID = "";
            var ListAnalysis4 = {}
            ListAnalysis4.columnName = "";
            ListAnalysis4.rowID = "";
            var ListAnalysis5 = {}
            ListAnalysis5.columnName = "";
            ListAnalysis5.rowID = "";

            function getReportTarget(rti) {
                var res;
                var jsondata = {
                    ReportID: rti
                };
                $.ajax({
                    type: "POST",
                    async: false,
                    url: docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/Reports/WebMethods.aspx/getReportTarget",
                    data: JSON.stringify(jsondata),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (msg) { res = msg.d; },
                });
                return res;
            }

            function getDefaultColumnReport(pt, cn) {
                var res;
                var jsondata = {
                    Group: pt,
                    columnName: cn
                };
                $.ajax({
                    type: "POST",
                    async: false,
                    url: docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/Reports/WebMethods.aspx/getDefaultColumnReport",
                    data: JSON.stringify(jsondata),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (msg) { res = msg.d; },
                });
                return res;
            }

            function getMenuXML(pt, cn) {
                var res;
                var jsondata = {
                    Group: pt,
                    columnName: cn
                };
                $.ajax({
                    type: "POST",
                    async: false,
                    url: docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/Reports/WebMethods.aspx/getMenuXML",
                    data: JSON.stringify(jsondata),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (msg) { res = msg.d; },
                });
                return res;
            }
            function getContextMenuListAnalysis1(sender, args) {
                var Report = args.get_item().get_value();
                Unisoft.PopUpWindow(Unisoft.WindowFileName(Report), Report, ListAnalysis1.columnName, ListAnalysis1.rowID);
            }
            function getContextMenuListAnalysis2(sender, args) {
                var Report = args.get_item().get_value();
                Unisoft.PopUpWindow(Unisoft.WindowFileName(Report), Report, ListAnalysis2.columnName, ListAnalysis2.rowID);
            }
            function getContextMenuListAnalysis3(sender, args) {
                var Report = args.get_item().get_value();
                Unisoft.PopUpWindow(Unisoft.WindowFileName(Report), Report, ListAnalysis3.columnName, ListAnalysis3.rowID);
            }
            function getContextMenuListAnalysis4(sender, args) {
                var Report = args.get_item().get_value();
                Unisoft.PopUpWindow(Unisoft.WindowFileName(Report), Report, ListAnalysis4.columnName, ListAnalysis4.rowID);
            }
            function getContextMenuListAnalysis5(sender, args) {
                var Report = args.get_item().get_value();
                Unisoft.PopUpWindow(Unisoft.WindowFileName(Report), Report, ListAnalysis5.columnName, ListAnalysis5.rowID);
            }


            function ValidatingForm(sender, args) {
                var validated = Page_ClientValidate('FilterGroup');

                if (!validated) return;
                else {
                    if ($('#BodyContentPlaceHolder_BodyContentPlaceHolder_ConsultantPanel').length === 1) {
                        if ($find('<%=RadListBox1.ClientID%>').get_checkedItems().length == 0) {
                            $find('<%=RadNotification1.ClientID%>').set_text("No consultant(s) selected!");
                            $find('<%=RadNotification1.ClientID%>').show();
                            validated = false;
                            args.set_cancel(true);
                        }
                    } else {
                        validated = true;
                    }
                }
            }

            $(document).ready(function () {
                $("#loaderPreview").hide().delay(1000);
                $("#AllOf").hide();
                $("#Since_wrapper").hide();
                $("#lbFor").hide();
                $("#n").hide();
                $("#DWMQY").hide();
                $("#selectAll").change(function () {
                    $("#EndoList :checkbox").prop('checked', $(this).prop("checked"));
                });

                $(".consultant-search").on('keyup', function () {
                    var item;
                    var search;
                    search = $(this).val(); //get textBox value
                    var availableUserList = $find("<%=RadListBox1.ClientID%>"); //Get RadList
                    if (search.length > 0) {
                        for (var i = 0; i < availableUserList._children.get_count(); i++) {
                            if (availableUserList.getItem(i).get_text().toLowerCase().match(search.toLowerCase())) {
                                availableUserList.getItem(i).select();
                            }
                            else {
                                availableUserList.getItem(i).unselect();
                            }
                        }
                    }
                    else {
                        availableUserList.clearSelection();
                        availableUserList.selectedIndex = -1;
                    }
                });
                $.extend($.expr[":"],
                    {
                        "contains-ci": function (elem, i, match, array) {
                            return (elem.TextContent || elem.innerText || $(elem).text() || "").toLowerCase().indexOf((match[3] || "").toLowerCase()) >= 0;
                        }
                    });
                $("#TypeOfConsultant_0").change(function () {
                    $("#EndoList .USNcb").show();
                    $("#EndoList .USNcb").find(":checkbox").prop('checked', false);
                });
                $("#TypeOfConsultant_1").change(function () {
                    $("#EndoList .E1True").show();
                    $("#EndoList .E1False").find(":checkbox").prop('checked', false);
                    $("#EndoList .E1False").hide();
                });
                $("#TypeOfConsultant_2").change(function () {
                    $("#EndoList .E2True").show();
                    $("#EndoList .E2False").find(":checkbox").prop('checked', false);
                    $("#EndoList .E2False").hide();
                });
                $("#TypeOfConsultant_3").change(function () {
                    $("#EndoList .LCTrue").show();
                    $("#EndoList .LCFalse").find(":checkbox").prop('checked', false);
                    $("#EndoList .LCFalse").hide();
                });
                $("#TypeOfConsultant_4").change(function () {
                    $("#EndoList .ASTrue").show();
                    $("#EndoList .ASFalse").find(":checkbox").prop('checked', false);
                    $("#EndoList .ASFalse").hide();
                });
                $("#TypeOfConsultant_5").change(function () {
                    $("#EndoList .N1True").show();
                    $("#EndoList .N1False").find(":checkbox").prop('checked', false);
                    $("#EndoList .N1False").hide();
                });
                $("#TypeOfConsultant_6").change(function () {
                    $("#EndoList .N2True").show();
                    $("#EndoList .N2False").find(":checkbox").prop('checked', false);
                    $("#EndoList .N2False").hide();
                });
                $("#TypeOfPeriod_0").change(function () {
                    $("#AllOf").hide();
                    $("#Since_wrapper").hide();
                    $("#lbFor").hide();
                    $("#n").hide();
                    $("#DWMQY").hide();
                });
                $("#TypeOfPeriod_1").change(function () {
                    $("#AllOf").show();
                    $("#Since_wrapper").show();
                    $("#lbFor").hide();
                    $("#n").hide();
                    $("#DWMQY").hide();
                });
                $("#TypeOfPeriod_2").change(function () {
                    $("#AllOf").hide();
                    $("#Since_wrapper").show();
                    $("#lbFor").hide();
                    $("#n").hide();
                    $("#DWMQY").hide();
                });
                $("#TypeOfPeriod_3").change(function () {
                    $("#AllOf").hide();
                    $("#Since_wrapper").show();
                    $("#lbFor").show();
                    $("#n").show();
                    $("#DWMQY").show();
                });
                $("#TypeOfPeriod_4").change(function () {
                    $("#AllOf").hide();
                    $("#Since_wrapper").hide();
                    $("#lbFor").hide();
                    $("#n").show();
                    $("#DWMQY").show();
                });
                $("#form1").fadeIn("slow");

                $("#<%=RadButtonFilter.ClientID%>").click(function (e, args) {
                    //showLoad();
                    //$("#loaderPreview").show().delay(1000);
                });

                $("#RadContextMenuListAnalysis1");
                $("#RadContextMenuListAnalysis2");
                $("#RadContextMenuListAnalysis3");
                $("#RadContextMenuListAnalysis4");
                $("#RadContextMenuListAnalysis5");
                $("#cbHideSuppressed").change(function () {
                    formChange();
                });
                $("#ComboConsultants_Input").change(function () {
                    formChange();
                });
                showHidepatientOptions();
                showHideSummaryOptions();
            });

            function hideLoad() {
               <%-- var currentUpdatedControl = "<%= RadTabStrip1.ClientID %>";
                var currentLoadingPanel = $find("<%= RadAjaxLoadingPanel1.ClientID %>");
                currentLoadingPanel.hide(currentUpdatedControl);--%>
            }
            function showLoad() {
               <%-- var currentLoadingPanel = $find("<%= RadAjaxLoadingPanel1.ClientID %>");
                var currentUpdatedControl = "<%= RadTabStrip1.ClientID %>";
                currentLoadingPanel.show(currentUpdatedControl);--%>
            }

            //$("#form1").fadeOut("slow");
            function formChange() {
                $("#ISMFilter").val("");
                ct = $("#ComboConsultants_Input").val();
                <%--var cb = document.getElementById("<%=cbHideSuppressed.ClientID%>").checked;--%>
                <%--var cb = document.getElementById("<%=cblOptions1.Items(0).ClientID%>").checked;
                var hs = "";
                if (cb === true) {
                    hs = "1";
                } else {
                    hs = "0";
                }--%>
                var listbox1 = $find("<%=RadListBox1.ClientID%>");
                var item1 = new Telerik.Web.UI.RadListBoxItem();
                var ItemsNo1 = listbox1.get_items().get_count();
                var usr = document.getElementById("<%=SUID.ClientID%>").value;
                var text = getConsultants("1", ct, "1", usr);
                var parser = new DOMParser();
                var xmlDoc = parser.parseFromString(text, "text/xml");
                x = xmlDoc.documentElement.getElementsByTagName("row");
                var Consultant = "";
                var ReportID = "";
                listbox1.get_items().clear();
                for (var i = 0; i < x.length; i++) {
                    Consultant = x[i].getAttribute("Consultant");
                    ReportID = x[i].getAttribute("ReportID");
                    var item1 = new Telerik.Web.UI.RadListBoxItem();
                    item1.set_text(Consultant);
                    item1.set_value(ReportID);
                    listbox1.get_items().add(item1);
                }
            <%--var listbox2 = $find("<%=RadListBox2.ClientID%>");
            var item2 = new Telerik.Web.UI.RadListBoxItem();
            var ItemsNo2 = listbox2.get_items().get_count();
            listbox2.get_items().clear();--%>
            }
            function getConsultants(lb, ct, hs, usr) {
                var docURL = document.URL;
                var res;
                var jsondata = {
                    listboxNo: lb,
                    ConsultantType: ct,
                    HideSuppressed: hs,
                    UserID: usr
                };
                $.ajax({
                    type: "POST",
                    async: false,
                    url: docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/Reports/WebMethods.aspx/getConsultants",
                    data: JSON.stringify(jsondata),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (msg) {
                        console.log(msg.d);
                        res = msg.d;
                    },
                    error: function (request, status, error) {
                        console.log(request.responseText);
                    }
                });
                return res;
            }

            $(".collapsible_header").click(function () {

                $header = $(this);
                //getting the next element
                $content = $header.next();
                //open up the content needed - toggle the slide- if visible, slide up, if not slidedown.
                $content.slideToggle(500, function () {
                    var $arrowSpan = $header.find('img');
                    if ($content.is(":visible")) {
                        $arrowSpan.attr("src", "../../Images/icons/collapse-arrow-down.png");
                    } else {
                        $arrowSpan.attr("src", "../../Images/icons/collapse-arrow-up.png");
                    }
                });
            });


            function showHidepatientOptions() {
                if (document.getElementById('<%=chkListPatients.ClientID%>').checked) {
                    document.getElementById('<%=patientOptions.ClientID%>').style.display = "block";
                }
                else {
                    document.getElementById('<%=patientOptions.ClientID%>').style.display = "none";
                }
            }

            function showHideSummaryOptions(checkBox) {
                if (document.getElementById('<%=chkSummaryForPeriod.ClientID%>').checked) {
                    document.getElementById('<%=summaryOptions.ClientID%>').style.display = "block";
                }
                else {
                    document.getElementById('<%=summaryOptions.ClientID%>').style.display = "none";
                }
            }


        </script>

    </telerik:RadScriptBlock>

</asp:Content>
