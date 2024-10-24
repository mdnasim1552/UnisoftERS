<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="GRS.aspx.vb" Inherits="UnisoftERS.Products_Reports_Grs" Debug="true" %>
<%--<%@ Register TagPrefix="asp" Namespace="System.Web.UI" Assembly="System.Web"%>--%>
<%@ Register TagPrefix="telerik" Namespace="Telerik.Web.UI" Assembly="Telerik.Web.UI" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script type="text/javascript" src="../../Scripts/global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>

    <script src="https://code.jquery.com/jquery-1.12.4.js"></script>
    <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>
    <link type="text/css" rel="stylesheet" href="//code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
   <%-- <link type="text/css" rel="stylesheet" href="/resources/demos/style.css">--%>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <telerik:RadScriptBlock runat="server">
        <style>
            .exportToExcelImage {
                background: url(../../Images/Excel-icon.png);
                background-position: 0 0;
                width: 5px;
                height: 5px;
            }

            .jagDivGrid {
                overflow: auto;
                max-height: 470px;
            }

        </style>

 <%--       <script type="text/javascript" src="/Scripts/Reports.js"></script>--%>
        <script type="text/javascript">

         
            function LeftMenuTreeView_NodeChecked(sender, args) {
                var thisNode = args.get_node();
                toggleTreeView(thisNode);
            }

            function toggleTreeView(thisNode) {
                $("#RTSP").show();

                var tabStrip = $find("<%=RadTabStripParameters.ClientID%>");
                var treeView = $find("<%= LeftMenuTreeView.ClientID%>");

                if (treeView == null) {
                    $("#RTSP").hide();
                    $("#GRSA01PV").hide();
                    return;
                }

                var nodes = treeView.get_allNodes();

                var thisNodeValue;
                var thisNodeChecked;
                if (thisNode != null) {
                    thisNodeValue = thisNode.get_attributes().getAttribute("CustomId");
                    thisNodeChecked = thisNode.get_checked();
                }

                var tabsVisible = 0;

                <%'Find number of nodes checked - maximum should be 7 %>
                for (var i = 0; i < nodes.length; i++) {
                    if (nodes[i].get_level() == 1) {
                        if (nodes[i].get_nodes() != null) {
                            if (nodes[i].get_checked()) {
                                tabsVisible++;
                            }
                        }
                    }
                }

                <%'If number of tabs selected > 7, exit function. %>
                if (tabsVisible > 7) {
                    thisNode.set_checked(false);
                    alert("Please select a maximum of 7 reports.");
                    return;
                }

                tabsVisible = 0;

                <%'Hide/show tabs %>
                for (var i = 0; i < nodes.length; i++) {
                    if (nodes[i].get_level() == 1) {
                        if (nodes[i].get_nodes() != null) {
                            var customId = nodes[i].get_attributes().getAttribute("CustomId");
                            var isChecked = nodes[i].get_checked();
                            var tab = tabStrip.findTabByValue(customId);
                            if (isChecked) {
                                tabsVisible++;
                                tab.set_visible(isChecked);
                                $("#" + customId + 'PV').show();
                                tab.select();
                            } else {
                                tab.set_visible(isChecked);
                                $("#" + customId + 'PV').hide();
                            }
                        }
                    }
                }

                <%'Set focus on tab checked%>
                if (tabsVisible > 0 && thisNodeChecked) {
                    var tabSel = tabStrip.findTabByValue(thisNodeValue);
                    if (tabSel != null) {
                        tabSel.select();
                        InitControls(thisNodeValue);
                    }
                } else if (tabsVisible == 0) {
                    $("#RTSP").hide();
                }
            }

            <%'Depending on tab selected, scroll to Selected Node in the treeview %>
            function RepTabSelected(sender, args) {
                var treeView = $find("<%= LeftMenuTreeView.ClientID%>");
                var node = treeView.findNodeByAttribute("CustomId", sender.get_selectedTab().get_value());
                if (node != null) {
                    node.select();
                    node.scrollIntoView();
                }
            }

            <%'Initialise controls in relevant tab page %>
            function InitControls(tabPage) {
                switch (tabPage) {
                    case "GRSA03":
                        $find("<%=FromAgeGRA3.ClientID%>").set_visible(false);
                        $find("<%=ToAgeGRA3.ClientID%>").set_visible(false);
                        break;
                    case "GRSB02":
                        $find("<%=FromAgeGRB2.ClientID%>").set_visible(false);
                        $find("<%=ToAgeGRB2.ClientID%>").set_visible(false);
                        break;
                    case "GRSB06":
                        $find("<%=FromAgeGRB6.ClientID%>").set_visible(false);
                        $find("<%=ToAgeGRB6.ClientID%>").set_visible(false);
                        break;
                    case "GRSC07":
                        $find("<%=FromAgeGRC7.ClientID%>").set_visible(false);
                        $find("<%=ToAgeGRC7.ClientID%>").set_visible(false);
                        var lbl_cb4GRC7 = $("#cb4GRC7").next('label');
                        $("#cb4GRC7").hide();
                        lbl_cb4GRC7.hide();
                        break;
                }
            }

            $(document).ready(function () {
                $("#radio1GRA3, #radio1GRB2, #radio1GRB6, #radio1GRC7").change(function () {
                    //localStorage.setItem("radio1GRA3", $("#radio1GRA3 :checked").val());

                    <%--                    switch (radioVal) {
                        case "All":
                            $find("<%=FromAgeGRA3.ClientID%>").set_visible(false); 
                        $find("<%=ToAgeGRA3.ClientID%>").set_visible(false);
                        break;
                    }--%>
                    var ctrlFromAge;
                    var ctrlToAge;
                    var tabId = this.id.slice(-2);
                    var radioVal = $("#radio1GR" + tabId + " :checked").val();

                    switch (tabId) {
                        case "A3":
                            ctrlFromAge = $find("<%=FromAgeGRA3.ClientID%>");
                            ctrlToAge = $find("<%=ToAgeGRA3.ClientID%>");
                            tabVal = $("#radio1GRA3 :checked").val();
                            break;
                        case "B2":
                            ctrlFromAge = $find("<%=FromAgeGRB2.ClientID%>");
                            ctrlToAge = $find("<%=ToAgeGRB2.ClientID%>");
                            break;
                        case "B6":
                            ctrlFromAge = $find("<%=FromAgeGRB6.ClientID%>");
                            ctrlToAge = $find("<%=ToAgeGRB6.ClientID%>");
                            break;
                        case "C7":
                            ctrlFromAge = $find("<%=FromAgeGRC7.ClientID%>");
                            ctrlToAge = $find("<%=ToAgeGRC7.ClientID%>");
                            break;
                    }

                    switch (radioVal) {
                        case "All":
                            ctrlFromAge.set_visible(false);
                            ctrlToAge.set_visible(false);
                            $("#lbl1GR" + tabId).text("(All age groups)");
                            $("#lbl1GR" + tabId).show();
                            $("#lbl2GR" + tabId).text(" ");
                            $("#lbl2GR" + tabId).hide();
                            break;
                        case "Under":
                            ctrlFromAge.set_visible(false);
                            ctrlToAge.set_visible(true);
                            $("#lbl1GR" + tabId).text(" ");
                            $("#lbl1GR" + tabId).hide();
                            $("#lbl2GR" + tabId).text("years of age");
                            $("#lbl2GR" + tabId).show();
                            break;
                        case "Over":
                            ctrlFromAge.set_visible(true);
                            ctrlToAge.set_visible(false);
                            $("#lbl1GR" + tabId).text("years of age");
                            $("#lbl1GR" + tabId).show();
                            $("#lbl2GR" + tabId).text(" ");
                            $("#lbl2GR" + tabId).hide();
                            break;
                        case "Between":
                            ctrlFromAge.set_visible(true);
                            ctrlToAge.set_visible(true);
                            $("#lbl1GR" + tabId).text("years and");
                            $("#lbl1GR" + tabId).show();
                            $("#lbl2GR" + tabId).text("years of age inclusive");
                            $("#lbl2GR" + tabId).show();
                            break;
                    }
                });

                $("#radio3GRC7").change(function () {
                    //localStorage.setItem("radio3GRC7", $("#radio3GRC7 :checked").val());
                    var lbl_cb3GRC7 = $("#cb3GRC7").next('label');
                    var lbl_cb4GRC7 = $("#cb4GRC7").next('label');
                    if ($("#radio3GRC7 input:radio:checked").val() == "1") {
                        $("#cb3GRC7").show();
                        lbl_cb3GRC7.show();
                        $("#cb4GRC7").hide();
                        lbl_cb4GRC7.hide();
                        //$("#lbl3GRC7").text("Include blanks as Zeroes");
                        <%--$find("<%=cb3GRC7.ClientID%>").style.display = 'none';
                        $find("<%=cb3GRC7.ClientID%>").nextSibling.style.display = 'none';
                        $find("<%=cb4GRC7.ClientID%>").style.display = 'none';
                        $find("<%=cb4GRC7.ClientID%>").nextSibling.style.display = 'none';--%>
                        <%--$find("<%=cb3GRC7.ClientID%>").set_visible(true);
                        $find("<%=cb4GRC7.ClientID%>").set_visible(false);--%>
                        //$("#cb3GRC7").show();
                        //$("#cb4GRC7").hide();
                        //$("#cb3GRC7").show();
                    }
                    if ($("#radio3GRC7 input:radio:checked").val() == "2") {
                        //$("#lbl3GRC7").text("Include null doses in calculations");
                        <%--$find("<%=cb3GRC7.ClientID%>").set_visible(false);
                        $find("<%=cb4GRC7.ClientID%>").set_visible(true);--%>
                        $("#cb3GRC7").hide();
                        lbl_cb3GRC7.hide();
                        $("#cb4GRC7").show();
                        lbl_cb4GRC7.show();
                        //$("#_rfdSkinnedcb3GRC7").show();
                    }
                    if ($("#radio3GRC7 input:radio:checked").val() == "3") {
                        //$("#lbl3GRC7").text("");
                        //$("#_rfdSkinnedcb3GRC7").hide();
                        <%--$find("<%=cb3GRC7.ClientID%>").set_visible(false);
                        $find("<%=cb4GRC7.ClientID%>").set_visible(false);--%>
                        $("#cb3GRC7").hide();
                        lbl_cb3GRC7.hide();
                        $("#cb4GRC7").hide();
                        lbl_cb4GRC7.hide();
                        //$("#cb3GRC7").val(false);
                        //$("#cb3GRC7").prop("checked", false)
                        //localStorage.setItem("cb3GRC7", false);
                    }

                });

                $("#chkWholeDB").change(function () {
                    $find("<%= RDPFrom.ClientID%>").set_enabled(!$(this).is(':checked'));
                    $find("<%= RDPTo.ClientID%>").set_enabled(!$(this).is(':checked'));
                });
            });


            function ValidatingDates(sender, args) {
                var dFrom = $find("<%= RDPFrom.ClientID%>").get_dateInput().get_selectedDate().format("yyyy/MM/dd");
                    var dTo = $find("<%= RDPTo.ClientID%>").get_dateInput().get_selectedDate().format("yyyy/MM/dd");
                    var dateFrom = new Date(dFrom);
                    var dateTo = new Date(dTo);
                    //if (dateFrom <= dateTo) {
                    //    for (var i = 0; i < GRSArray.length; i++) {
                    //        changeTabStatus(i);
                    //    }
                    //} else {
                    //    args.set_cancel(true);
                    //}
                }

        </script>
    </telerik:RadScriptBlock>
</head>
<body onload="toggleTreeView(null);">
    <form id="form1" runat="server">
        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
        </telerik:RadAjaxLoadingPanel>
        <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server">
        </telerik:RadStyleSheetManager>
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="RadButtonFilter">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="RadButtonFilter"></telerik:AjaxUpdatedControl>
                        <telerik:AjaxUpdatedControl ControlID="RadTabStripReports" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                <%--        <telerik:AjaxUpdatedControl ControlID="RadTabStrip2" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                        <telerik:AjaxUpdatedControl ControlID="RadGridGastroscopy" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                        <telerik:AjaxUpdatedControl ControlID="RadGridPEGPEJ" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                        <telerik:AjaxUpdatedControl ControlID="RadGridERCP" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                        <telerik:AjaxUpdatedControl ControlID="RadGridColonoscopy" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                        <telerik:AjaxUpdatedControl ControlID="RadGridSigmoidoscopy" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                        <telerik:AjaxUpdatedControl ControlID="RadGridEndoscopists" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                        <telerik:AjaxUpdatedControl ControlID="RadPageView1" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                        <telerik:AjaxUpdatedControl ControlID="RadPageView2" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                        <telerik:AjaxUpdatedControl ControlID="FilterPanel" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                        <telerik:AjaxUpdatedControl ControlID="Panel1" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>--%>
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
        </telerik:RadScriptManager>
        <telerik:RadSkinManager ID="RadSkinManager1" runat="server" Skin="Office2010Blue" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ControlsRadPane" Skin="Web20" />
        <div id="ContentDiv" class="">
            <table>
                <tr>
                    <td>
                        <div class="optionsHeading">GRS Reports</div>
                    </td>
                    <td>
                        <div id="ButtonExport">
                            <telerik:RadButton ID="RadButtonExportGrids" runat="server" Text="Export Grids to Excel" Enabled="False" Skin="Silk" Style="height: 30px;" Font-Bold="true">
                            </telerik:RadButton>
                        </div>
                    </td>
                </tr>
            </table>

            <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="95%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0">
                <telerik:RadPane ID="ControlsRadPane" runat="server" Height="650px">
                    <asp:Panel ID="Panel1" runat="server">
                        <div style="margin: 0px 10px; width: 95%;">
                            <div style="margin-top: 10px;"></div>

                            <telerik:RadTabStrip ID="RadTabStripReports" runat="server" MultiPageID="RadMultiPageReports" SelectedIndex="0" Skin="MetroTouch" RenderMode="Lightweight" Font-Size="Larger">
                                <Tabs>
                                    <telerik:RadTab runat="server" Text="Filter" Selected="True" PageViewID="RadPageView1" Width="80" Style="text-align: center;">
                                    </telerik:RadTab>
                                </Tabs>
                            </telerik:RadTabStrip>


                        <%--    <telerik:RadTabStrip ID="RadTabStrip1" runat="server" MultiPageID="RadMultiPage1" SelectedIndex="0" Skin="MetroTouch" RenderMode="Lightweight" Font-Size="Larger">
                                <Tabs>
                                    <telerik:RadTab Text="Filter" Value="1" Font-Bold="false" Selected="true" PageViewID="RadPageView1" Width="80" Style="text-align: center;" />
                                    <telerik:RadTab Text="Preview" Value="2" Font-Bold="false" PageViewID="RadPageView2" Selected="false" Enabled="false" />
                                </Tabs>
                            </telerik:RadTabStrip>--%>
                            <telerik:RadMultiPage ID="RadMultiPageReports" runat="server" CssClass="ConfigureBg"> <!-- added CssClass="ConfigureBg" to show the Blue grad around the inner-border! Shawkat; 2017-06-13 -->
                                <telerik:RadPageView ID="RadPageView1" runat="server" Selected="true">
                                    <div style="padding-bottom: 1em; height:500px;" class="">
                                        <table id="ControlsTable" runat="server" class="optionsBodyText" style="margin-top: 15px; margin-left: 15px;" cellpadding="0" cellspacing="0">
                                            <tr>
                                                <td>
                                                    <asp:Panel ID="FilterPanel" runat="server">
                                                        <asp:ObjectDataSource ID="SqlDSAllConsultants" runat="server" SelectMethod="GetConsultantsListBox1" TypeName="UnisoftERS.Reporting">
                                                            <SelectParameters>
                                                                <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                                                            </SelectParameters>
                                                        </asp:ObjectDataSource>
                                                        <asp:ObjectDataSource ID="SqlDSSelectedConsultants" runat="server" SelectMethod="GetConsultantsListBox2" TypeName="UnisoftERS.Reporting">
                                                            <SelectParameters>
                                                                <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                                                            </SelectParameters>
                                                        </asp:ObjectDataSource>

                                                        <table>
                                                            <tr>
                                                                <td style="vertical-align: top;">

                                                                    <div style="border: 1px solid #c2d2e2; width: 415px; background-color: #F9F9FF;">
                                                                        <div class="filterRepHeader">
                                                                            <span style="padding-left: 5px;">GRS Reports</span>

                                                                        </div>
                                                                        <div class="content" style="height: 230px;">
                                                                            <div style="padding-left: 0px;">
                                                                                <telerik:RadAjaxPanel ID="RadAjaxPanel1" runat="server" Height="225px">
                                                                                    <%--<table style="border: 1px solid #c2d2e2; background-color: #ececff;">
                                                                                        <tr>
                                                                                            <td>--%>

                                                                                    <telerik:RadTreeView ID="LeftMenuTreeView" Skin="Office2010Blue" runat="server" Width="415px" Height="230px" CheckChildNodes="True" TriStateCheckBoxes="False" CheckBoxes="True" OnClientNodeChecked="LeftMenuTreeView_NodeChecked">
                                                                                        <DataBindings>
                                                                                            <telerik:RadTreeNodeBinding DataMember="Node" CssClass="class" ImageUrlField="ImageUrl" ToolTip="ToolTip" CssClassField="cssAttrib" />
                                                                                        </DataBindings>
                                                                                    </telerik:RadTreeView>



                                                                                    <%--<telerik:RadListBox ID="RadListBox2" runat="server" Width="387px" Height="200px" Skin="Silk"
                                                                                                    CheckBoxes="true" ShowCheckAll="true"
                                                                                                    SelectionMode="Multiple" DataSourceID="SqlDSAllConsultants" DataKeyField="ReportID" DataTextField="Consultant"
                                                                                                    DataValueField="ReportID">
                                                                                                </telerik:RadListBox>--%>
                                                                                    <%--</td>
                                                                                        </tr>
                                                                                    </table>--%>
                                                                                </telerik:RadAjaxPanel>
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                </td>


                                                                <td rowspan="2" style="vertical-align: top; padding-left: 15px; text-align: left;">

                                                                    <div style="border: 1px solid #c2d2e2;">
                                                                        <div class="filterRepHeader">
                                                                            <span style="padding-left: 5px;">Consultant</span>

                                                                        </div>
                                                                        <div class="content" style="height: 270px; width: 330px;">

                                                                            <%--<fieldset>
                                                                        <legend><b>Consultant</b></legend>--%>
                                                                            <table style="padding: 5px 0px 0px 5px;">
                                                                                <tr>
                                                                                    <td style="" colspan="2">
                                                                                        <table id="FilterConsultant" runat="server" border="0">
                                                                                            <tr>
                                                                                                <td style="">
                                                                                                    <asp:Label ID="Label1" runat="server" Text="Type word(s) to filter on: "></asp:Label>
                                                                                                </td>
                                                                                                <td>
                                                                                                    <telerik:RadTextBox runat="server" ID="ISMFilter" Width="160px" EmptyMessage="Consultant name" Skin="Windows7"></telerik:RadTextBox>
                                                                                                </td>
                                                                                            </tr>
                                                                                            <tr>
                                                                                                <td>
                                                                                                    <asp:Label ID="Label2" runat="server" Text="Consultants type: "></asp:Label>
                                                                                                </td>
                                                                                                <td style="text-align: left;">
                                                                                                    <%--<td style="text-align: right;">--%>
                                                                                                    <telerik:RadComboBox ID="ComboConsultants" runat="server" Width="160px" AutoPostBack="True" Skin="Windows7">
                                                                                                        <Items>
                                                                                                            <telerik:RadComboBoxItem runat="server" Text="All" Value="all" />
                                                                                                            <telerik:RadComboBoxItem runat="server" Text="Assistants or trainees" Value="Asst" />
                                                                                                            <telerik:RadComboBoxItem runat="server" Text="Endoscopist 1" Value="Endoscopist1" />
                                                                                                            <telerik:RadComboBoxItem runat="server" Text="Endoscopist 2" Value="Endoscopist2" />
                                                                                                            <telerik:RadComboBoxItem runat="server" Text="List Consultant" Value="ListConsultant" />
                                                                                                            <telerik:RadComboBoxItem runat="server" Text="Nurse 1" Value="Nurse1" />
                                                                                                            <telerik:RadComboBoxItem runat="server" Text="Nurse 2" Value="Nurse2" />
                                                                                                        </Items>
                                                                                                    </telerik:RadComboBox>
                                                                                                    <asp:EntityDataSource ID="entityERSDB" runat="server">
                                                                                                    </asp:EntityDataSource>
                                                                                                </td>
                                                                                            </tr>
                                                                                            <tr>
                                                                                                <td colspan="2" style="vertical-align: top; padding-top: 5px;">
                                                                                                    <div>
                                                                                                        <telerik:RadAjaxPanel ID="RadAjaxPanel2" runat="server" Height="170px">
                                                                                                            <table style="border: 1px solid #c2d2e2; background-color: #ececff;">
                                                                                                                <tr>
                                                                                                                    <td>
                                                                                                                        <telerik:RadListBox ID="RadListBox1" runat="server" Width="297px" Height="160px" Skin="Silk"
                                                                                                                            CheckBoxes="True" ShowCheckAll="True"
                                                                                                                            SelectionMode="Multiple" DataKeyField="UserId" DataTextField="Consultant"
                                                                                                                            DataValueField="UserId" DataSortField="Consultant" Sort="Ascending">
                                                                                                                        </telerik:RadListBox>
                                                                                                                    </td>
                                                                                                                </tr>
                                                                                                            </table>
                                                                                                        </telerik:RadAjaxPanel>
                                                                                                    </div>
                                                                                                </td>
                                                                                            </tr>
                                                                                            <tr>
                                                                                                <td colspan="2">
                                                                                                    <asp:CheckBox ID="cbHideSuppressed" runat="server" Text="Hide suppressed endoscopists" Skin="Windows7" CssClass="mutuallyexclusive" />
                                                                                                </td>
                                                                                            </tr>
                                                                                        </table>
                                                                                    </td>


                                                                                </tr>
                                                                            </table>
                                                                        </div>
                                                                    </div>

                                                                    <div style="margin-top: 8px; text-align: center;">
                                                                        <telerik:RadButton ID="RadButtonClear" runat="server" Text="Clear selection" Skin="Web20" ValidationGroup="FilterGroup" OnClientClicking="ValidatingDates" SkinID="RadSkinManager1" Icon-PrimaryIconUrl="~/Images/icons/clear.png"></telerik:RadButton>
                                                                        <telerik:RadButton ID="RadButtonFilter" runat="server" Text="Apply filter" Skin="Web20" SkinID="RadSkinManager1" Icon-PrimaryIconUrl="~/Images/icons/filter.png" Font-Bold="true" Width="210"></telerik:RadButton>
                                                                    </div>

                                                                    <%-- </fieldset>--%>
                                                                </td>
                                                            </tr>

                                                            <tr>
                                                                <td style="padding-top: 5px;">
                                                                    <div style="border: 1px solid #c2d2e2; width: 415px;">
                                                                        <div class="filterRepHeader">
                                                                            <span style="padding-left: 5px;">Dates</span>
                                                                            <span style="float: right;"><asp:CheckBox ID="chkWholeDB" runat="server" Text="All (whole database)" /></span>
                                                                        </div>
                                                                        <div class="content" style="height: 40px;">
                                                                            <div>
                                                                                <table runat="server" border="0" style="padding-left: 5px; padding-top: 5px;">
                                                                                    <tr>
                                                                                        <td style="text-align: right">From: 
                                                                                        </td>
                                                                                        <td>
                                                                                            <telerik:RadDatePicker ID="RDPFrom" runat="server" Width="140px" Skin="Windows7" />
                                                                                        </td>
                                                                                        <td style="text-align: right;">To:
                                                                                        </td>
                                                                                        <td>
                                                                                            <telerik:RadDatePicker ID="RDPTo" runat="server" Width="140px" Skin="Windows7" />
                                                                                        </td>
                                                                                    </tr>
                                                                                </table>
                                                                                <asp:HiddenField ID="SUID" runat="server" />
                                                                                <asp:RequiredFieldValidator runat="server" ID="RequiredFieldValidatorFromDate" ControlToValidate="RDPFrom" ErrorMessage="Invalid date from." SetFocusOnError="True" ValidationGroup="FilterGroup" ForeColor="Red" BackColor="#FBFF94"></asp:RequiredFieldValidator>
                                                                                <asp:RequiredFieldValidator runat="server" ID="RequiredfieldvalidatorToDate" ControlToValidate="RDPTo" ErrorMessage="Invalid date to." ValidationGroup="FilterGroup" ForeColor="Red" BackColor="#FBFF94"></asp:RequiredFieldValidator>
                                                                                <asp:CompareValidator ID="dateCompareValidator" runat="server" ControlToValidate="RDPTo" ControlToCompare="RDPFrom" Operator="GreaterThan" ValidationGroup="FilterGroup" Type="Date" ErrorMessage="Date to should be after date from." SetFocusOnError="True" ForeColor="Red" BackColor="#FBFF94"></asp:CompareValidator>
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                </td>
                                                            </tr>

                                                            <tr>
                                                                <td colspan="2" style="padding-top: 5px; width: 400px;">
                                                                    <div class="componentsContainer">
                                                                        <asp:Panel ID="MiniFilterPanel" runat="server">

                                                                            <div runat="server" id="RTSP" style="display:none; ">
                                                                                <telerik:RadTabStrip ID="RadTabStripParameters" runat="server" MultiPageID="RadMultiPageParameters" SelectedIndex="0" Skin="Silk" RenderMode="Lightweight" OnClientTabSelected="RepTabSelected">
                                                                                    <Tabs>
                                                                                        <telerik:RadTab runat="server" Text="GRS A-1" PageViewID="GRSA01PV" ToolTip="GRS A-1 Diagnostic biopsies for diarrhoea" Value="GRSA01">
                                                                                        </telerik:RadTab>
                                                                                        <telerik:RadTab runat="server" Text="GRS A-2" PageViewID="GRSA02PV" ToolTip="GRS A-2 Haemostasis after endoscopy therapy" Value="GRSA02">
                                                                                        </telerik:RadTab>
                                                                                        <telerik:RadTab runat="server" Text="GRS A-3" PageViewID="GRSA03PV" ToolTip="GRS A-3 Stent and PEG/PEJ placement" Value="GRSA03">
                                                                                        </telerik:RadTab>
                                                                                        <telerik:RadTab runat="server" Text="GRS A-4" PageViewID="GRSA04PV" ToolTip="GRS A-4 Use of reversing agent" Value="GRSA04">
                                                                                        </telerik:RadTab>
                                                                                        <telerik:RadTab runat="server" Text="GRS B-1" PageViewID="GRSB01PV" ToolTip="GRS B-1 Assessment of sedation/comfort" Value="GRSB01">
                                                                                        </telerik:RadTab>
                                                                                        <telerik:RadTab runat="server" Text="GRS B-2" PageViewID="GRSB02PV" ToolTip="GRS B-2 Analysis of colonic polyps/polypectomies" Value="GRSB02">
                                                                                        </telerik:RadTab>
                                                                                        <telerik:RadTab runat="server" Text="GRS B-3" PageViewID="GRSB03PV" ToolTip="GRS B-3 Completion of intended therapeutic ERCP" Value="GRSB03">
                                                                                        </telerik:RadTab>
                                                                                        <telerik:RadTab runat="server" Text="GRS B-4" PageViewID="GRSB04PV" ToolTip="GRS B-4 Decompression of obstructed ducts" Value="GRSB04">
                                                                                        </telerik:RadTab>
                                                                                        <telerik:RadTab runat="server" Text="GRS B-5" PageViewID="GRSB05PV" ToolTip="GRS B-5 Repeat OGD for Gastric Ulcers" Value="GRSB05">
                                                                                        </telerik:RadTab>
                                                                                        <telerik:RadTab runat="server" Text="GRS B-6" PageViewID="GRSB06PV" ToolTip="GRS B-6 Tattoing of small tumours and suspected malignant polyps" Value="GRSB06">
                                                                                        </telerik:RadTab>
                                                                                        <telerik:RadTab runat="server" Text="GRS C-1" PageViewID="GRSC01PV" ToolTip="GRS C-1 Adenoma/polyp detection rate" Value="GRSC01">
                                                                                        </telerik:RadTab>
                                                                                        <telerik:RadTab runat="server" Text="GRS C-2" PageViewID="GRSC02PV" ToolTip="GRS C-2 Colonoscopy completion summary" Value="GRSC02">
                                                                                        </telerik:RadTab>
                                                                                        <telerik:RadTab runat="server" Text="GRS C-3" PageViewID="GRSC03PV" ToolTip="GRS C-3 Colonoscopy detailed failure report" Value="GRSC03">
                                                                                        </telerik:RadTab>
                                                                                        <telerik:RadTab runat="server" Text="GRS C-4" PageViewID="GRSC04PV" ToolTip="GRS C-4 Analysis of colonoscopy bowel prep. (Boston)" Value="GRSC04">
                                                                                        </telerik:RadTab>
                                                                                        <telerik:RadTab runat="server" Text="GRS C-5" PageViewID="GRSC05PV" ToolTip="GRS C-5 Analysis of colonoscopy bowel prep. (Standard)" Value="GRSC05">
                                                                                        </telerik:RadTab>
                                                                                        <telerik:RadTab runat="server" Text="GRS C-6" PageViewID="GRSC06PV" ToolTip="GRS C-6 Quality of bowel preparation with repeats" Value="GRSC06">
                                                                                        </telerik:RadTab>
                                                                                        <telerik:RadTab runat="server" Text="GRS C-7" PageViewID="GRSC07PV" ToolTip="GRS C-7 Sedation and analgesia for all procedures" Value="GRSC07">
                                                                                        </telerik:RadTab>
                                                                                        <telerik:RadTab runat="server" Text="GRS C-8" PageViewID="GRSC08PV" ToolTip="GRS C-8 successful Intubation and Completion of OGD" Value="GRSC08">
                                                                                        </telerik:RadTab>
                                                                                    </Tabs>
                                                                                </telerik:RadTabStrip>
                                                                            </div>
                                                                        </asp:Panel>
                                                                    </div>

                                                                    <div>
                                                                        <telerik:RadMultiPage ID="RadMultiPageParameters" runat="server" SelectedIndex="0">
                                                                            <telerik:RadPageView ID="GRSA01PV" runat="server" >
                                                                                <div class="multiPageDivTab">
                                                                                    <fieldset>
                                                                                        <legend>Diagnostic biopsies for diarrhoea</legend>
                                                                                        <p>
                                                                                            Select date range and click on Filter button.
                                                                                            <%--1) Select the corresponding tab for every particular filter conditions and then, click on the Filter button--%>
                                                                                        </p>
                                                                                        <%--<p>
                                                                                            2) New tabs will appear at the top of this page.
                                                                                        </p>
                                                                                        <p id="resetlocal">
                                                                                            If you would like to clear your settings, click <b onclick="localStorage.clear();$('#resetlocal').hide();">here</b>
                                                                                        </p>--%>
                                                                                    </fieldset>
                                                                                </div>
                                                                            </telerik:RadPageView>
                                                                            <telerik:RadPageView ID="GRSA02PV" runat="server">
                                                                                <div class="multiPageDivTab">
                                                                                    <table class="checkboxesTable">
                                                                                        <tr>
                                                                                            <%--<td>
                                                                                                <fieldset class="otherDataFieldset2">
                                                                                                    <legend>Which endoscopist?</legend>
                                                                                                    <asp:CheckBox ID="cb1GRA2" runat="server" Text="As endoscopist 1" AutoPostBack="False" CssClass="dfltVal" Skin="Web20" />
                                                                                                    <asp:CheckBox ID="cb2GRA2" runat="server" Text="As endoscopist 2" AutoPostBack="False" CssClass="dfltVal" Skin="Web20" />
                                                                                                </fieldset>
                                                                                            </td>--%>
                                                                                            <td>
                                                                                                <fieldset class="otherDataFieldset2" style="width: 400px;">
                                                                                                    <legend>Procedure</legend>
                                                                                                    <asp:CheckBox ID="cb3GRA2" runat="server" Text="OGD" AutoPostBack="False" CssClass="dfltVal" Skin="Windows7" /><br />
                                                                                                    <asp:CheckBox ID="cb4GRA2" runat="server" Text="Colon/Sigmoidoscopy" AutoPostBack="False" CssClass="dfltVal" Skin="Windows7" />
                                                                                                </fieldset>
                                                                                            </td>
                                                                                        </tr>
                                                                                    </table>
                                                                                </div>
                                                                            </telerik:RadPageView>
                                                                            <telerik:RadPageView ID="GRSA03PV" runat="server">
                                                                                <div class="multiPageDivTab">
                                                                                    <table class="checkboxesTable">
                                                                                        <tr>
                                                                                            <td style="width: 350px; padding-right: 20px;">
                                                                                                <fieldset class="otherDataFieldset2">
                                                                                                    <legend>Age at procedure</legend>

                                                                                                    <asp:RadioButtonList ID="radio1GRA3" runat="server" RepeatDirection="Horizontal" AutoPostBack="false" RepeatColumns="4"  >
                                                                                                        <asp:ListItem Value="All" Selected="True">All</asp:ListItem>
                                                                                                        <asp:ListItem Value="Under">Under</asp:ListItem>
                                                                                                        <asp:ListItem Value="Over">Over</asp:ListItem>
                                                                                                        <asp:ListItem Value="Between">Between</asp:ListItem>
                                                                                                    </asp:RadioButtonList>

                                                                                                    <telerik:RadNumericTextBox ID="FromAgeGRA3" runat="server" Skin="Windows7"
                                                                                                        IncrementSettings-InterceptMouseWheel="false" IncrementSettings-Step="5"
                                                                                                        Width="35px" MaxValue="200" MinValue="0">
                                                                                                        <NumberFormat DecimalDigits="0" />
                                                                                                    </telerik:RadNumericTextBox>
                                                                                                    <%--<asp:TextBox ID="FromAgeGRA3" Text="0" MaxLength="3" runat="server" Width="50" style="display:none;"></asp:TextBox>--%>
                                                                                                    <asp:Label ID="lbl1GRA3" runat="server" Text="(All age groups)"></asp:Label>
                                                                                                    <telerik:RadNumericTextBox ID="ToAgeGRA3" runat="server" Skin="Windows7"
                                                                                                        IncrementSettings-InterceptMouseWheel="false" IncrementSettings-Step="5"
                                                                                                        Width="35px" MaxValue="200" MinValue="0">
                                                                                                        <NumberFormat DecimalDigits="0" />
                                                                                                    </telerik:RadNumericTextBox>
                                                                                                    <%--<asp:TextBox ID="ToAgeGRA3" Text="70" MaxLength="3" runat="server" Width="50" Style="display: none;"></asp:TextBox>--%>
                                                                                                    <asp:Label ID="lbl2GRA3" runat="server" Text="Years of age inclusive" Style="display: none;"></asp:Label>
                                                                                                </fieldset>
                                                                                            </td>
                                                                                            <td style="vertical-align: top; border-left: 1px dashed #c2d2e2; padding-left: 20px;">
                                                                                                <%--<fieldset class="otherDataFieldset2">
                                                                                                    <legend>Age at procedure</legend>--%>
                                                                                                <asp:CheckBox ID="cb1GRA3" runat="server" Text="oesophageal stent (following stricture)" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                <br />
                                                                                                <asp:CheckBox ID="cb2GRA3" runat="server" Text="duodenal stent" AutoPostBack="False" CssClass="dfltVal" />

                                                                                                <asp:CheckBox ID="cb3GRA3" runat="server" Text="colonic stent" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                <br />
                                                                                                <asp:CheckBox ID="cb4GRA3" runat="server" Text="percutaneous endoscopic gastrostomy (PEG)" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                <br />
                                                                                                <asp:CheckBox ID="cb5GRA3" runat="server" Text="percutaneous endoscopic jejunostomy (PEJ)" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                <%--</fieldset>--%><br />

                                                                                            </td>
                                                                                        </tr>
                                                                                        <tr>
                                                                                            <td>
                                                                                                <%-- <fieldset>
                                                                                                    <legend>Summary</legend>--%>
                                                                                                <asp:RadioButtonList ID="radio2GRA3" runat="server" RepeatDirection="Horizontal" AutoPostBack="false">
                                                                                                    <asp:ListItem Value="Count" Selected="True">Count of procedures</asp:ListItem>
                                                                                                    <asp:ListItem Value="List">List of Patients involved</asp:ListItem>
                                                                                                </asp:RadioButtonList>

                                                                                                <%--</fieldset>--%>
                                                                                            </td>
                                                                                            <td style="border-top: 1px dashed #c2d2e2; border-left: 1px dashed #c2d2e2; padding-left: 20px;">
                                                                                                <asp:CheckBox ID="cb6GRA3" runat="server" Text="Include endoscopy unit as a whole" AutoPostBack="False" CssClass="dfltVal" />
                                                                                            </td>
                                                                                        </tr>

                                                                                    </table>
                                                                                </div>
                                                                            </telerik:RadPageView>
                                                                            <telerik:RadPageView ID="GRSA04PV" runat="server">
                                                                                <div class="multiPageDivTab">
                                                                                    <table class="checkboxesTable">
                                                                                        <tr>
                                                                                            <td>
                                                                                                <fieldset class="otherDataFieldset2" style="width: 400px;">
                                                                                                    <legend>Summary</legend>
                                                                                                    <asp:CheckBox ID="cb1GRA4" runat="server" Text="Include summary" AutoPostBack="False" CssClass="dfltVal" /><br />
                                                                                                    <asp:CheckBox ID="cb2GRA4" runat="server" Text="Include list of patients and doses" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                </fieldset>
                                                                                            </td>
                                                                                        </tr>
                                                                                    </table>
                                                                                </div>
                                                                            </telerik:RadPageView>
                                                                            <telerik:RadPageView ID="GRSB01PV" runat="server">
                                                                                <div class="multiPageDivTab">
                                                                                    <table class="checkboxesTable">
                                                                                        <tr>
                                                                                            <td>
                                                                                                <fieldset class="otherDataFieldset2" style="width: 600px;">
                                                                                                    <legend>Assessment of sedation / comfort</legend>
                                                                                                    <asp:CheckBox ID="cb1GRA5" runat="server" Text="Include endoscopy unit as a whole" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                    <br />
                                                                                                    <asp:CheckBox ID="cb2GRA5" runat="server" Text="List of procedures where nurses assessment of patients discomfort during the procedure scored greater than or equal to 4" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                </fieldset>
                                                                                            </td>
                                                                                        </tr>
                                                                                    </table>
                                                                                </div>
                                                                            </telerik:RadPageView>
                                                                            <telerik:RadPageView ID="GRSB02PV" runat="server">
                                                                                <div class="multiPageDivTab">
                                                                                    <table class="checkboxesTable">
                                                                                        <tr>
                                                                                            <td style="vertical-align: top; width: 350px; padding-right: 20px;">
                                                                                                <fieldset class="otherDataFieldset2">
                                                                                                    <legend>Age at procedure</legend>
                                                                                                    <asp:RadioButtonList ID="radio1GRB2" runat="server" RepeatDirection="Horizontal" AutoPostBack="false">
                                                                                                        <asp:ListItem Value="All" Selected="True">All</asp:ListItem>
                                                                                                        <asp:ListItem Value="Under">Under</asp:ListItem>
                                                                                                        <asp:ListItem Value="Over">Over</asp:ListItem>
                                                                                                        <asp:ListItem Value="Between">Between</asp:ListItem>
                                                                                                    </asp:RadioButtonList>
                                                                                                    <telerik:RadNumericTextBox ID="FromAgeGRB2" runat="server" Skin="Windows7"
                                                                                                        IncrementSettings-InterceptMouseWheel="false" IncrementSettings-Step="5"
                                                                                                        Width="35px" MaxValue="200" MinValue="0">
                                                                                                        <NumberFormat DecimalDigits="0" />
                                                                                                    </telerik:RadNumericTextBox>
                                                                                                    <%--<asp:TextBox ID="FromAgeGRB1" Text="0" MaxLength="3" CssClass="grsrep number" runat="server"></asp:TextBox>--%>
                                                                                                    <asp:Label ID="lbl1GRB2" runat="server" Text="(All age groups)"></asp:Label>
                                                                                                    <telerik:RadNumericTextBox ID="ToAgeGRB2" runat="server" Skin="Windows7"
                                                                                                        IncrementSettings-InterceptMouseWheel="false" IncrementSettings-Step="5"
                                                                                                        Width="35px" MaxValue="200" MinValue="0">
                                                                                                        <NumberFormat DecimalDigits="0" />
                                                                                                    </telerik:RadNumericTextBox>
                                                                                                    <%--<asp:TextBox ID="ToAgeGRB1" Text="70" MaxLength="3" CssClass="grsrep number" runat="server"></asp:TextBox>--%>
                                                                                                    <asp:Label ID="lbl2GRB2" runat="server" Text="Years of age inclusive" Style="display: none;"></asp:Label>
                                                                                                </fieldset>
                                                                                            </td>
                                                                                            <td>
                                                                                                <fieldset class="otherDataFieldset2">
                                                                                                    <legend>Polyps (greater than)</legend>
                                                                                                    <table style="width:250px;"  >
                                                                                                        <%--<tr>
                                                                                                            <td></td>
                                                                                                            <td><span>greater than</span></td>
                                                                                                        </tr>--%>
                                                                                                        <tr>
                                                                                                            <td>
                                                                                                                <asp:CheckBox ID="cb1GRB2" runat="server" Text="Sessile" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                            </td>
                                                                                                            <td> &gt;&nbsp; 
                                                                                                                <telerik:RadNumericTextBox ID="in1GRB2" runat="server" Skin="Windows7"
                                                                                                                    IncrementSettings-InterceptMouseWheel="false" IncrementSettings-Step="5"
                                                                                                                    Width="35px" MaxValue="900" MinValue="0">
                                                                                                                    <NumberFormat DecimalDigits="0" />
                                                                                                                </telerik:RadNumericTextBox>mm
                                                                                                                <%--<input id="in1GRB2" runat="server" type="number" value="0" min="0" max="200" step="1" size="3" maxlength="3"  />
                                                                                                                <span>mm</span>--%>

                                                                                                            </td>
                                                                                                        </tr>
                                                                                                        <tr>
                                                                                                            <td>
                                                                                                                <asp:CheckBox ID="cb2GRB2" runat="server" Text="Pedunculated" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                            </td>
                                                                                                            <td> &gt;&nbsp; 
                                                                                                                <telerik:RadNumericTextBox ID="in2GRB2" runat="server" Skin="Windows7"
                                                                                                                    IncrementSettings-InterceptMouseWheel="false" IncrementSettings-Step="5"
                                                                                                                    Width="35px" MaxValue="900" MinValue="0">
                                                                                                                    <NumberFormat DecimalDigits="0" />
                                                                                                                </telerik:RadNumericTextBox>mm
                                                                                                                <%--<input runat="server" id="in2GRB2" type="number" value="0" min="0" max="200" step="1" size="3" maxlength="3"  />
                                                                                                                <span>mm</span>--%>

                                                                                                            </td>
                                                                                                        </tr>
                                                                                                        <tr>
                                                                                                            <td>
                                                                                                                <asp:CheckBox ID="cb3GRB2" runat="server" Text="Pseudopolyp" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                            </td>
                                                                                                            <td> &gt;&nbsp; 
                                                                                                                <telerik:RadNumericTextBox ID="in3GRB2" runat="server" Skin="Windows7"
                                                                                                                    IncrementSettings-InterceptMouseWheel="false" IncrementSettings-Step="5"
                                                                                                                    Width="35px" MaxValue="900" MinValue="0">
                                                                                                                    <NumberFormat DecimalDigits="0" />
                                                                                                                </telerik:RadNumericTextBox>mm
                                                                                                                <%--<input id="in3GRB2" runat="server" type="number" value="0" min="0" max="200" step="1" size="3" maxlength="3"  />
                                                                                                                <span>mm</span>--%>

                                                                                                            </td>
                                                                                                        </tr>
                                                                                                    </table>
                                                                                                </fieldset>
                                                                                            </td>
                                                                                        </tr>
                                                                                    </table>
                                                                                </div>
                                                                            </telerik:RadPageView>
                                                                            <telerik:RadPageView ID="GRSB03PV" runat="server">
                                                                                <div class="multiPageDivTab">
                                                                                    <table class="checkboxesTable">
                                                                                        <tr>
                                                                                            <td>
                                                                                                <fieldset class="otherDataFieldset2">
                                                                                                    <legend>Age at procedure</legend>
                                                                                                    <asp:RadioButtonList ID="radio1GRB3" runat="server" RepeatDirection="Horizontal" AutoPostBack="false" RepeatLayout="Flow">
                                                                                                        <asp:ListItem Value="All" Selected="True">All</asp:ListItem>
                                                                                                        <asp:ListItem Value="Under">Under</asp:ListItem>
                                                                                                        <asp:ListItem Value="Over">Over</asp:ListItem>
                                                                                                        <asp:ListItem Value="Between">Between</asp:ListItem>
                                                                                                    </asp:RadioButtonList>
                                                                                                    <asp:TextBox ID="FromAgeGRB3" Text="0" MaxLength="3" runat="server"></asp:TextBox>
                                                                                                    <asp:Label ID="lbl1GRB3" runat="server" Text="Years and"></asp:Label>
                                                                                                    <asp:TextBox ID="ToAgeGRB3" Text="70" MaxLength="3" runat="server"></asp:TextBox>
                                                                                                    <asp:Label ID="lbl2GRB3" runat="server" Text="Years of age inclusive"></asp:Label>
                                                                                                </fieldset>
                                                                                            </td>
                                                                                            <td style="vertical-align: top;">
                                                                                                <fieldset class="otherDataFieldset2">
                                                                                                    <legend>Which endoscopist?</legend>
                                                                                                    <asp:CheckBox ID="cb1GRB3" runat="server" Text="As endoscopist 1" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                    <asp:CheckBox ID="cb2GRB3" runat="server" Text="As endoscopist 2" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                </fieldset>
                                                                                            </td>
                                                                                        </tr>
                                                                                    </table>
                                                                                </div>
                                                                            </telerik:RadPageView>
                                                                            <telerik:RadPageView ID="GRSB04PV" runat="server">
                                                                                <div class="multiPageDivTab">
                                                                                    <table class="checkboxesTable">
                                                                                        <tr>
                                                                                            <td style="vertical-align: top;">
                                                                                                <fieldset class="otherDataFieldset2">
                                                                                                    <legend>Age at procedure</legend>
                                                                                                    <asp:RadioButtonList ID="radio1GRB4" runat="server" RepeatDirection="Horizontal" AutoPostBack="false">
                                                                                                        <asp:ListItem Value="All" Selected="True">All</asp:ListItem>
                                                                                                        <asp:ListItem Value="Under">Under</asp:ListItem>
                                                                                                        <asp:ListItem Value="Over">Over</asp:ListItem>
                                                                                                        <asp:ListItem Value="Between">Between</asp:ListItem>
                                                                                                    </asp:RadioButtonList>
                                                                                                    <asp:TextBox ID="FromAgeGRB4" Text="0" MaxLength="3" runat="server"></asp:TextBox>
                                                                                                    <asp:Label ID="lbl1GRB4" runat="server" Text="Years and"></asp:Label>
                                                                                                    <asp:TextBox ID="ToAgeGRB4" Text="70" MaxLength="3" runat="server"></asp:TextBox>
                                                                                                    <asp:Label ID="lbl2GRB4" runat="server" Text="Years of age inclusive"></asp:Label>
                                                                                                </fieldset>
                                                                                            </td>
                                                                                            <td>
                                                                                                <fieldset class="otherDataFieldset2">
                                                                                                    <legend>Which endoscopist?</legend>
                                                                                                    <asp:CheckBox ID="cb1GRB4" runat="server" Text="As endoscopist 1" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                    <asp:CheckBox ID="cb2GRB4" runat="server" Text="As endoscopist 2" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                </fieldset>
                                                                                                <fieldset class="otherDataFieldset2">
                                                                                                    <legend>Summary</legend>
                                                                                                    <asp:CheckBox ID="cb3GRB4" runat="server" Text="Include endoscopy unit as a whole" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                </fieldset>
                                                                                            </td>
                                                                                        </tr>
                                                                                    </table>
                                                                                </div>
                                                                            </telerik:RadPageView>
                                                                            <telerik:RadPageView ID="GRSB05PV" runat="server">
                                                                                <div class="multiPageDivTab">
                                                                                    <fieldset class="otherDataFieldset2">
                                                                                        <legend>Repeat OGD for Gastric Ulcers</legend>
                                                                                        <p>
                                                                                            <asp:Label ID="Label3" runat="server" Text="Select date range and click on Filter button."></asp:Label>
                                                                                        </p>
                                                                                    </fieldset>
                                                                                </div>
                                                                            </telerik:RadPageView>
                                                                            <telerik:RadPageView ID="GRSB06PV" runat="server">
                                                                                <div class="multiPageDivTab">
                                                                                    <table>
                                                                                        <tr>
                                                                                            <td style="vertical-align: top;">
                                                                                                <table>
                                                                                                    <%--<tr>
                                                                                                        <td>
                                                                                                            <asp:CheckBox ID="cb1GRB6" runat="server" Text="As endoscopist 1" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                            <asp:CheckBox ID="cb2GRB6" runat="server" Text="As endoscopist 2" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                        </td>
                                                                                                    </tr>--%>
                                                                                                    <tr>
                                                                                                        <td>
                                                                                                            <fieldset class="otherDataFieldset2">
                                                                                                                <legend>Age at procedure</legend>
                                                                                                                <asp:RadioButtonList ID="radio1GRB6" runat="server" RepeatDirection="Horizontal" AutoPostBack="false">
                                                                                                                    <asp:ListItem Value="All" Selected="True">All</asp:ListItem>
                                                                                                                    <asp:ListItem Value="Under">Under</asp:ListItem>
                                                                                                                    <asp:ListItem Value="Over">Over</asp:ListItem>
                                                                                                                    <asp:ListItem Value="Between">Between</asp:ListItem>
                                                                                                                </asp:RadioButtonList>
                                                                                                                <telerik:RadNumericTextBox ID="FromAgeGRB6" runat="server" Skin="Windows7"
                                                                                                                    IncrementSettings-InterceptMouseWheel="false" IncrementSettings-Step="5"
                                                                                                                    Width="35px" MaxValue="200" MinValue="0">
                                                                                                                    <NumberFormat DecimalDigits="0" />
                                                                                                                </telerik:RadNumericTextBox>
                                                                                                                <%--<asp:TextBox ID="FromAgeGRB6" Text="0" MaxLength="3" runat="server"></asp:TextBox>--%>
                                                                                                                <asp:Label ID="lbl1GRB6" runat="server" Text="(All age groups)"></asp:Label>
                                                                                                                <telerik:RadNumericTextBox ID="ToAgeGRB6" runat="server" Skin="Windows7"
                                                                                                                    IncrementSettings-InterceptMouseWheel="false" IncrementSettings-Step="5"
                                                                                                                    Width="35px" MaxValue="200" MinValue="0">
                                                                                                                    <NumberFormat DecimalDigits="0" />
                                                                                                                </telerik:RadNumericTextBox>
                                                                                                                <%--<asp:TextBox ID="ToAgeGRB6" Text="70" MaxLength="3" runat="server"></asp:TextBox>--%>
                                                                                                                <asp:Label ID="lbl2GRB6" runat="server" Text="Years of age inclusive" style="display: none;"></asp:Label>
                                                                                                            </fieldset>
                                                                                                        </td>
                                                                                                    </tr>
                                                                                                </table>
                                                                                            </td>
                                                                                            <td style="border-left: 1px dashed #c2d2e2;font-size:11px;">
                                                                                                <%--<fieldset class="otherDataFieldset2">
                                                                                                    <legend>Polyps and tumours</legend>--%>
                                                                                                    <table class="checkboxesTable">
                                                                                                        <tr>
                                                                                                            <td style="vertical-align: top;padding-left:10px;">
                                                                                                                <div style="border: 1px solid #c2d2e2;">
                                                                                                                    <div class="filterRepHeader">
                                                                                                                        <span style="padding-left: 5px; width: 50px;">Polyps (greater than)</span>
                                                                                                                    </div>
                                                                                                                    <div class="content" >
                                                                                                                        <div>
                                                                                                                            <table style="min-width: 170px;">
                                                                                                                                <tr>
                                                                                                                                    <td>
                                                                                                                                        <asp:CheckBox ID="cb1Tumour" runat="server" Text="Sessile" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                                                    </td>
                                                                                                                                    <td>&gt;&nbsp; 
                                                                                                                                        <telerik:RadNumericTextBox ID="in1GB6" runat="server" Skin="Windows7"
                                                                                                                                            IncrementSettings-InterceptMouseWheel="false" IncrementSettings-Step="5"
                                                                                                                                            Width="35px" MaxValue="900" MinValue="0">
                                                                                                                                            <NumberFormat DecimalDigits="0" />
                                                                                                                                        </telerik:RadNumericTextBox>mm
                                                                                                                                        <%--<input id="in1GB6" runat="server" type="number" value="20" min="0" max="999" step="1" size="2" maxlength="3" />--%>
                                                                                                                                    </td>
                                                                                                                                </tr>
                                                                                                                                <tr>
                                                                                                                                    <td>
                                                                                                                                        <asp:CheckBox ID="cb2Tumour" runat="server" Text="Pedunculated" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                                                    </td>
                                                                                                                                    <td>&gt;&nbsp; 
                                                                                                                                        <telerik:RadNumericTextBox ID="in2GB6" runat="server" Skin="Windows7"
                                                                                                                                            IncrementSettings-InterceptMouseWheel="false" IncrementSettings-Step="5"
                                                                                                                                            Width="35px" MaxValue="900" MinValue="0">
                                                                                                                                            <NumberFormat DecimalDigits="0" />
                                                                                                                                        </telerik:RadNumericTextBox>mm
                                                                                                                                        <%--<input id="in2GB6" runat="server" type="number" value="20" min="0" max="999" step="1" size="2" maxlength="3" />--%>
                                                                                                                                    </td>
                                                                                                                                </tr>
                                                                                                                            </table>
                                                                                                                        </div>
                                                                                                                    </div>
                                                                                                                </div>
                                                                                                            </td>
                                                                                                            <td style="padding-left:15px;">
                                                                                                                <div style="border: 1px solid #c2d2e2;">
                                                                                                                    <div class="filterRepHeader">
                                                                                                                        <span style="padding-left: 5px; width: 50px;">Tumours (greater than)</span>
                                                                                                                    </div>
                                                                                                                    <div class="content" >
                                                                                                                        <div>
                                                                                                                            <table style="min-width: 160px;">
                                                                                                                                <tr>
                                                                                                                                    <td>
                                                                                                                                        <asp:CheckBox ID="cb3Tumour" runat="server" Text="Submucosal" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                                                    </td>
                                                                                                                                    <td>&gt;&nbsp; 
                                                                                                                                        <telerik:RadNumericTextBox ID="in3GB6" runat="server" Skin="Windows7"
                                                                                                                                            IncrementSettings-InterceptMouseWheel="false" IncrementSettings-Step="5"
                                                                                                                                            Width="35px" MaxValue="900" MinValue="0">
                                                                                                                                            <NumberFormat DecimalDigits="0" />
                                                                                                                                        </telerik:RadNumericTextBox>mm
                                                                                                                                        <%--<input id="in3GB6" runat="server" type="number" value="20" min="0" max="999" step="1" size="2" maxlength="3" />--%>
                                                                                                                                    </td>
                                                                                                                                </tr>
                                                                                                                                <tr>
                                                                                                                                    <td>
                                                                                                                                        <asp:CheckBox ID="cb4Tumour" runat="server" Text="Villous" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                                                    </td>
                                                                                                                                    <td>&gt;&nbsp; 
                                                                                                                                        <telerik:RadNumericTextBox ID="in4GB6" runat="server" Skin="Windows7"
                                                                                                                                            IncrementSettings-InterceptMouseWheel="false" IncrementSettings-Step="5"
                                                                                                                                            Width="35px" MaxValue="900" MinValue="0">
                                                                                                                                            <NumberFormat DecimalDigits="0" />
                                                                                                                                        </telerik:RadNumericTextBox>mm
                                                                                                                                        <%--<input id="in4GB6" runat="server" type="number" value="20" min="0" max="999" step="1" size="2" maxlength="3" />--%>
                                                                                                                                    </td>
                                                                                                                                </tr>
                                                                                                                                <tr>
                                                                                                                                    <td>
                                                                                                                                        <asp:CheckBox ID="cb5Tumour" runat="server" Text="Ulcerative" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                                                    </td>
                                                                                                                                    <td>&gt;&nbsp; 
                                                                                                                                        <telerik:RadNumericTextBox ID="in5GB6" runat="server" Skin="Windows7"
                                                                                                                                            IncrementSettings-InterceptMouseWheel="false" IncrementSettings-Step="5"
                                                                                                                                            Width="35px" MaxValue="900" MinValue="0">
                                                                                                                                            <NumberFormat DecimalDigits="0" />
                                                                                                                                        </telerik:RadNumericTextBox>mm
                                                                                                                                        <%--<input id="in5GB6" runat="server" type="number" value="20" min="0" max="999" step="1" size="2" maxlength="3" />--%>
                                                                                                                                    </td>
                                                                                                                                </tr>
                                                                                                                                <tr>
                                                                                                                                    <td>
                                                                                                                                        <asp:CheckBox ID="cb6Tumour" runat="server" Text="Stricturing" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                                                    </td>
                                                                                                                                    <td>&gt;&nbsp; 
                                                                                                                                        <telerik:RadNumericTextBox ID="in6GB6" runat="server" Skin="Windows7"
                                                                                                                                            IncrementSettings-InterceptMouseWheel="false" IncrementSettings-Step="5"
                                                                                                                                            Width="35px" MaxValue="900" MinValue="0">
                                                                                                                                            <NumberFormat DecimalDigits="0" />
                                                                                                                                        </telerik:RadNumericTextBox>mm
                                                                                                                                        <%--<input id="in6GB6" runat="server" type="number" value="20" min="0" max="999" step="1" size="2" maxlength="3" />--%>
                                                                                                                                    </td>
                                                                                                                                </tr>
                                                                                                                                <tr>
                                                                                                                                    <td>
                                                                                                                                        <asp:CheckBox ID="cb7Tumour" runat="server" Text="Polypoidal" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                                                    </td>
                                                                                                                                    <td>&gt;&nbsp; 
                                                                                                                                        <telerik:RadNumericTextBox ID="in7GB6" runat="server" Skin="Windows7"
                                                                                                                                            IncrementSettings-InterceptMouseWheel="false" IncrementSettings-Step="5"
                                                                                                                                            Width="35px" MaxValue="900" MinValue="0">
                                                                                                                                            <NumberFormat DecimalDigits="0" />
                                                                                                                                        </telerik:RadNumericTextBox>mm
                                                                                                                                        <%--<input id="in7GB6" runat="server" type="number" value="20" min="0" max="999" step="1" size="2" maxlength="3" />--%>
                                                                                                                                    </td>
                                                                                                                                </tr>
                                                                                                                            </table>
                                                                                                                        </div>
                                                                                                                    </div>
                                                                                                                </div>
                                                                                                            </td>
                                                                                                        </tr>
                                                                                                    </table>
                                                                                               <%-- </fieldset>--%>
                                                                                            </td>
                                                                                        </tr>
                                                                                    </table>
                                                                                </div>
                                                                            </telerik:RadPageView>
                                                                            <telerik:RadPageView ID="GRSC01PV" runat="server">
                                                                                <div class="multiPageDivTab">
                                                                                    <table class="checkboxesTable">
                                                                                        <tr>
                                                                                            <%--<td>
                                                                                                <fieldset class="otherDataFieldset2">
                                                                                                    <legend>Which endoscopist?</legend>
                                                                                                    <asp:CheckBox ID="cb1GRC1" runat="server" Text="As endoscopist 1" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                    <asp:CheckBox ID="cb2GRC1" runat="server" Text="As endoscopist 2" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                </fieldset>
                                                                                            </td>--%>
                                                                                            <td style="vertical-align :top;width:300px;">
                                                                                                <fieldset class="otherDataFieldset2">
                                                                                                    <legend>Procedure</legend>
                                                                                                    <asp:RadioButtonList ID="radio1GRC1" runat="server" RepeatDirection="Vertical" AutoPostBack="false">
                                                                                                        <asp:ListItem Value="COL" Selected="True">Colonoscopy</asp:ListItem>
                                                                                                        <asp:ListItem Value="SIG">Sigmoidoscopy</asp:ListItem>
                                                                                                    </asp:RadioButtonList>
                                                                                                </fieldset>
                                                                                            </td>
                                                                                        </tr>
                                                                                    </table>
                                                                                </div>
                                                                            </telerik:RadPageView>
                                                                            <telerik:RadPageView ID="GRSC02PV" runat="server">
                                                                                <div class="multiPageDivTab">
                                                                                    <table class="checkboxesTable">
                                                                                        <tr>
                                                                                            <%--<td>
                                                                                                <fieldset class="otherDataFieldset2">
                                                                                                    <legend>Which endoscopist?</legend>
                                                                                                    <asp:CheckBox ID="cb1GRC2" runat="server" Text="As endoscopist 1" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                    <asp:CheckBox ID="cb2GRC2" runat="server" Text="As endoscopist 2" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                </fieldset>
                                                                                            </td>--%>
                                                                                            <td>
                                                                                                <fieldset class="otherDataFieldset2">
                                                                                                    <legend>Summary</legend>
                                                                                                    <asp:CheckBox ID="cb3GRC2" runat="server" Text="Include endoscopy unit as a whole" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                </fieldset>
                                                                                            </td>
                                                                                        </tr>
                                                                                    </table>
                                                                                </div>
                                                                            </telerik:RadPageView>
                                                                            <telerik:RadPageView ID="GRSC03PV" runat="server">
                                                                                <div class="multiPageDivTab">
                                                                                    <table class="checkboxesTable">
                                                                                        <tr>
                                                                                            <%--<td>
                                                                                                <fieldset class="otherDataFieldset2">
                                                                                                    <legend>Which endoscopist?</legend>
                                                                                                    <asp:CheckBox ID="cb1GRC3" runat="server" Text="As endoscopist 1" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                    <asp:CheckBox ID="cb2GRC3" runat="server" Text="As endoscopist 2" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                </fieldset>
                                                                                            </td>--%>
                                                                                            <td style="vertical-align :top;width:300px;" >
                                                                                                <fieldset class="otherDataFieldset2">
                                                                                                    <legend>Procedure</legend>
                                                                                                    <asp:RadioButtonList ID="radio1GRC3" runat="server" RepeatDirection="Vertical" AutoPostBack="false">
                                                                                                        <asp:ListItem Value="COL" Selected="True">Colonoscopy</asp:ListItem>
                                                                                                        <asp:ListItem Value="SIG">Sigmoidoscopy</asp:ListItem>
                                                                                                    </asp:RadioButtonList>
                                                                                                </fieldset>
                                                                                            </td>
                                                                                            <td style="vertical-align :top;width:300px;" >
                                                                                                <fieldset class="otherDataFieldset2">
                                                                                                    <legend>Additional parameters</legend>
                                                                                                    <asp:CheckBox ID="cb3GRC3" runat="server" Text="Include perioperative complications" AutoPostBack="False" CssClass="dfltVal" /><br/>
                                                                                                    <asp:CheckBox ID="cb4GRC3" runat="server" Text="Include reversal agents" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                </fieldset>
                                                                                            </td>
                                                                                        </tr>

                                                                                    </table>
                                                                                </div>
                                                                            </telerik:RadPageView>
                                                                            <telerik:RadPageView ID="GRSC04PV" runat="server">
                                                                                <div class="multiPageDivTab">
                                                                                    <table class="checkboxesTable">
                                                                                        <tr>
                                                                                            <td style="vertical-align :top;width:300px;" >
                                                                                                <fieldset class="otherDataFieldset2">
                                                                                                    <legend>Procedure</legend>
                                                                                                    <asp:RadioButtonList ID="radio1GRC4" runat="server" RepeatDirection="Vertical" AutoPostBack="false">
                                                                                                        <asp:ListItem Value="COL" Selected="True">Colonoscopy</asp:ListItem>
                                                                                                        <asp:ListItem Value="SIG">Sigmoidoscopy</asp:ListItem>
                                                                                                    </asp:RadioButtonList>
                                                                                                </fieldset>
                                                                                            </td>
                                                                                        </tr>
                                                                                    </table>
                                                                                </div>
                                                                            </telerik:RadPageView>
                                                                            <telerik:RadPageView ID="GRSC05PV" runat="server">
                                                                                <div class="multiPageDivTab">
                                                                                    <table class="checkboxesTable">
                                                                                        <tr>
                                                                                            <td style="vertical-align :top;width:300px;" >
                                                                                                <fieldset class="otherDataFieldset2">
                                                                                                    <legend>Procedure</legend>
                                                                                                    <asp:RadioButtonList ID="radio1GRC5" runat="server" RepeatDirection="Vertical" AutoPostBack="false">
                                                                                                        <asp:ListItem Value="COL" Selected="True">Colonoscopy</asp:ListItem>
                                                                                                        <asp:ListItem Value="SIG">Sigmoidoscopy</asp:ListItem>
                                                                                                    </asp:RadioButtonList>
                                                                                                </fieldset>
                                                                                            </td>
                                                                                        </tr>
                                                                                    </table>
                                                                                </div>
                                                                            </telerik:RadPageView>
                                                                            <telerik:RadPageView ID="GRSC06PV" runat="server">
                                                                                <div class="multiPageDivTab">
                                                                                    <table class="checkboxesTable">
                                                                                        <tr>
                                                                                            <td style="vertical-align :top;width:300px;" >
                                                                                                <fieldset class="otherDataFieldset2">
                                                                                                    <legend>Procedure</legend>
                                                                                                    <asp:RadioButtonList ID="radio1GRC6" runat="server" RepeatDirection="Vertical" AutoPostBack="false">
                                                                                                        <asp:ListItem Value="COL" Selected="True">Colonoscopy</asp:ListItem>
                                                                                                    </asp:RadioButtonList>
                                                                                                </fieldset>
                                                                                            </td>
                                                                                        </tr>
                                                                                    </table>
                                                                                </div>
                                                                            </telerik:RadPageView>
                                                                            <telerik:RadPageView ID="GRSC07PV" runat="server">
                                                                                <div class="multiPageDivTab">
                                                                                    <table class="adjusted">
                                                                                        <tr>
                                                                                            <td style="vertical-align: top;">
                                                                                                <fieldset class="otherDataFieldset2">
                                                                                                    <legend>Age at procedure</legend>
                                                                                                    <asp:RadioButtonList ID="radio1GRC7" runat="server" RepeatDirection="Horizontal" AutoPostBack="false">
                                                                                                        <asp:ListItem Value="All" Selected="True">All</asp:ListItem>
                                                                                                        <asp:ListItem Value="Under">Under</asp:ListItem>
                                                                                                        <asp:ListItem Value="Over">Over</asp:ListItem>
                                                                                                        <asp:ListItem Value="Between">Between</asp:ListItem>
                                                                                                    </asp:RadioButtonList>
                                                                                                    <telerik:RadNumericTextBox ID="FromAgeGRC7" runat="server" Skin="Windows7"
                                                                                                        IncrementSettings-InterceptMouseWheel="false" IncrementSettings-Step="5"
                                                                                                        Width="35px" MaxValue="200" MinValue="0">
                                                                                                        <NumberFormat DecimalDigits="0" />
                                                                                                    </telerik:RadNumericTextBox>
                                                                                                    <%--<asp:TextBox ID="FromAgeGRC7" Text="0" MaxLength="3" runat="server"></asp:TextBox>--%>
                                                                                                    <asp:RequiredFieldValidator runat="server" ID="FromAgeGRC7FV" ControlToValidate="FromAgeGRC7" Display="Dynamic" ErrorMessage="Value is required" ValidationGroup="FilterGroup"></asp:RequiredFieldValidator>
                                                                                                    <asp:Label ID="lbl1GRC7" runat="server" Text="(All age groups)"></asp:Label>
                                                                                                    <telerik:RadNumericTextBox ID="ToAgeGRC7" runat="server" Skin="Windows7"
                                                                                                        IncrementSettings-InterceptMouseWheel="false" IncrementSettings-Step="5"
                                                                                                        Width="35px" MaxValue="200" MinValue="0">
                                                                                                        <NumberFormat DecimalDigits="0" />
                                                                                                    </telerik:RadNumericTextBox>
                                                                                                    <%--<asp:TextBox ID="ToAgeGRC7" Text="70" MaxLength="3" runat="server">70</asp:TextBox>--%>
                                                                                                    <asp:RequiredFieldValidator runat="server" ID="ToAgeGRC7FV" ControlToValidate="ToAgeGRC7" Display="Dynamic" ErrorMessage="Value is required" ValidationGroup="FilterGroup"></asp:RequiredFieldValidator>
                                                                                                    <asp:Label ID="lbl2GRC7" runat="server" Text="Years of age inclusive" style="display: none;"></asp:Label>
                                                                                                </fieldset>
                                                                                                <fieldset class="otherDataFieldset2">
                                                                                                    <legend>Procedure</legend>
                                                                                                    <asp:RadioButtonList ID="radio2GRC7" runat="server" RepeatDirection="Horizontal" AutoPostBack="false">
                                                                                                        <asp:ListItem Value="OGD" Selected="True">OGD</asp:ListItem>
                                                                                                        <asp:ListItem Value="ERC">ERCP</asp:ListItem>
                                                                                                        <asp:ListItem Value="PRO">Proct.</asp:ListItem>
                                                                                                        <asp:ListItem Value="COL">Colon.</asp:ListItem>
                                                                                                        <asp:ListItem Value="SIG">Sigmoid.</asp:ListItem>
                                                                                                    </asp:RadioButtonList>
                                                                                                </fieldset>
                                                                                            </td>
                                                                                            <td style="vertical-align: top;width:400px;">
                                                                                                <fieldset class="otherDataFieldset2">
                                                                                                    <legend>Output As</legend>
                                                                                                    <table>
                                                                                                        <tr>
                                                                                                            <td>
                                                                                                                <asp:RadioButtonList ID="radio3GRC7" runat="server" RepeatDirection="Vertical" AutoPostBack="false">
                                                                                                                    <asp:ListItem Value="1" Selected="True">List of patients</asp:ListItem>
                                                                                                                    <asp:ListItem Value="2">Mean dosage values</asp:ListItem>
                                                                                                                    <asp:ListItem Value="3">Median dosage values</asp:ListItem>
                                                                                                                </asp:RadioButtonList>
                                                                                                            </td>

                                                                                                            <td style=" vertical-align: top;width:200px;font-size:11px;">
                                                                                                                <asp:CheckBox ID="cb3GRC7" runat="server" Text="Include blanks as Zeroes" AutoPostBack="False" /><br/><br/>
                                                                                                                <asp:CheckBox ID="cb4GRC7" runat="server" Text="Include null doses in calculations" AutoPostBack="False" />
                                                                                                                <%--<telerik:RadLabel ID="lbl3GRC7" runat="server" Text="Include blanks as Zeroes">
                                                                                                                </telerik:RadLabel>--%>
                                                                                                            </td>
                                                                                                        </tr>
                                                                                                    </table>
                                                                                                    
                                                                                                </fieldset>
                                                                                            </td>
                                                                                        </tr>
                                                                                        <tr>
                                                                                            <td></td>
                                                                                            <td style="vertical-align: top;">
                                                                                                
                                                                                            </td>
                                                                                            
                                                                                        </tr>
                                                                                    </table>
                                                                                </div>
                                                                            </telerik:RadPageView>
                                                                            <telerik:RadPageView ID="GRSC08PV" runat="server">
                                                                                <div class="multiPageDivTab">
                                                                                    <fieldset class="otherDataFieldset2">
                                                                                        <legend>Summary</legend>
                                                                                        <asp:CheckBox ID="cb1GRC8" runat="server" Text="Include endoscopy unit as a whole" AutoPostBack="False" CssClass="dfltVal" /><br/>
                                                                                        <asp:CheckBox ID="cb2GRC8" runat="server" Text="List patients where not completed" AutoPostBack="False" CssClass="dfltVal" />
                                                                                    </fieldset>
                                                                                </div>
                                                                            </telerik:RadPageView>
                                                                        </telerik:RadMultiPage>
                                                                    </div>
                                                                </td>
                                                            </tr>


                                                        </table>
                                                    </asp:Panel>
                                                </td>
                                            </tr>
                                        </table>
                                    </div>

                                </telerik:RadPageView>

                            </telerik:RadMultiPage>
                        </div>


                    </asp:Panel>
                </telerik:RadPane>
            </telerik:RadSplitter>

            <telerik:RadWindowManager ID="RadWindowManager1" runat="server" Animation="Fade" AutoSize="true" Modal="True" RenderMode="Classic" VisibleStatusbar="False" Skin="Metro" MinHeight="500px" MinWidth="650px">
                <Windows>
                    <telerik:RadWindow ID="RadWindow1" runat="server" Title="Related procedures" VisibleOnPageLoad="False" MinHeight="500px" MinWidth="650px" AutoSize="true" VisibleStatusbar="false" Modal="true">
                        <ContentTemplate>
                            <div id="MiniWindow1">
                            </div>
                        </ContentTemplate>
                    </telerik:RadWindow>
                </Windows>
            </telerik:RadWindowManager>
        </div>
        <telerik:RadScriptBlock ID="dsa" runat="server">
        <script type="text/javascript">


            //LeftMenuTreeView_NodeChecked();
            //$("#RTSP").hide();
            //$("#GRSA01PV").hide();
            //toggleTreeView(null);

            //for (var i = 0; i < tabs.get_count() ; i++) {

            //    //tabs.getTab(i).set_visible(false);
            //    alert(tabs.getTab(i).get_text());
            //}
            //$("#RTSP").hide();
            //toggleTabs(false);
            $(document).load(function () {
                
            });


        </script>
            </telerik:RadScriptBlock>
    </form>
</body>
</html>


<%--<asp:Content ID="Content1" ContentPlaceHolderID="HeadContentPlaceHolder" runat="server">
    <link href="/Styles/Reporting.css" rel="stylesheet" />
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="/Scripts/Reports.js"></script>
<telerik:RadScriptBlock runat="server">
<script type="text/javascript" id="telerikClientEvents1">
    function ValidatingDates(sender, args) {
        var dFrom = $find("<%= RDPFrom.ClientID%>").get_dateInput().get_selectedDate().format("yyyy/MM/dd");
        var dTo = $find("<%= RDPTo.ClientID%>").get_dateInput().get_selectedDate().format("yyyy/MM/dd");
        var dateFrom = new Date(dFrom);
        var dateTo = new Date(dTo);
        if (dateFrom <= dateTo) {
            for (var i = 0; i < GRSArray.length; i++) {
                changeTabStatus(i);

            }
        } else {
            args.set_cancel(true);
        }
    }
    function ResolveUrl(url) {
        if (url.indexOf("~/") == 0) {
            url = baseUrl + url.substring(2);
        }
        return url;
    }
    function SetUrl(node) {
    }
    function ClientNodeClickedR(sender, eventArgs) {
        var node = eventArgs.get_node();
        if (node.get_nodes().get_count() == 0) {
            SetUrl(node);
            if (node.check() == true) {
                node.uncheck();
            } else {
                node.check();
            }
            var UnisoftGRS = node.get_attributes().getAttribute("GRS");
            console.log(node.get_value());
            index = eval(UnisoftGRS);
            GRSArray[index] = !GRSArray[index];
            if (GRSArray[index] == false) {
                GRSArray[index] = false;
                node.uncheck();
            } else {
                GRSArray[index] = true;
                node.check();
            }
            if (UnisoftGRS != "") {
                changeTabStatus(index);
                var tbArray = "";
                for (var i = 0; i < GRSArray.length ; i++) {
                    if (GRSArray[i] === true) {
                        tbArray = tbArray + "1";
                    } else {
                        tbArray = tbArray + "0";
                    }
                }
                $("#BodyContentPlaceHolder_tbGRSArray").val(tbArray);
            }
            else {
                console.log(node.get_value());
                //ojito
                loadDoc(node.get_value());
                //document.getElementById("DeploySite").setAttribute("src", node.get_value());
                //<iframe id="DeployFrame" src="JAGGRS.aspx" runat="server" class="if"></iframe>
                //telerikDemo.radXmlHttpPanel.set_value(urlSearchString);
            }
        }
        else {
            node.expand();
            SetUrl(node.get_allNodes()[0]);
            node.get_allNodes()[0].select();
        }
    }

    function loadDoc(filename) {
        var xhttp = new XMLHttpRequest();
        xhttp.onreadystatechange = function () {
            if (xhttp.readyState == 4 && xhttp.status == 200) {
                document.getElementById("BodyContentPlaceHolder_ReportURL").innerHTML = xhttp.responseText;
            }
        };
        xhttp.open("GET", filename, true);
        xhttp.send();
    }
    function LeftMenuTreeView_NodeChecked(sender, args) {
        console.log(LeftMenuTreeView_NodeChecked(sender, args));
    }
    function LeftMenuTreeView_NodeChecked(sender, args) {
        var ThisNode = args.get_node();
        var UnisoftGRS = ThisNode.get_attributes().getAttribute("GRS");
        var isChecked = args.get_node().get_checked();
        var tabStripText;
        var index = 0;
        index = eval(UnisoftGRS);
        GRSArray[index] = isChecked;
        changeTabStatus(index);
        var tbArray = "";
        for (var i = 0; i < GRSArray.length ; i++) {
            if (GRSArray[i] === true) {
                tbArray = tbArray + "1";
            } else {
                tbArray = tbArray + "0";
            }
        }
        $("#BodyContentPlaceHolder_tbGRSArray").val(tbArray);
    }
    </script>
     </telerik:RadScriptBlock> 
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="LeftPaneContentPlaceHolder" runat="server">
    <div class="tabsContainer">
        <telerik:RadTabStrip ID="RadTabStrip1" runat="server" MultiPageID="MainMultiPage" Skin="WebBlue" AutoPostBack="true" OnTabClick="RadTabStrip1_TabClick1">
            <Tabs>
                <telerik:RadTab runat="server" Text="GRS" Selected="true"  PageViewID="GRSPageView" ToolTip="GRS reports" />
            </Tabs>
        </telerik:RadTabStrip>
    </div>
    <telerik:RadFormDecorator ID="RadFormDecorator2" runat="server" DecoratedControls="All" DecorationZoneID="LeftTreePane" Skin="Web20" />
    <div id="LeftTreePane" class="treeListBorder" style="margin-top: -5px;height:100%;">
        <telerik:RadTreeView ID="LeftMenuTreeView" runat="server" OnClientNodeClicked="ClientNodeClickedR" CheckChildNodes="True" TriStateCheckBoxes="False" CheckBoxes="True" OnClientNodeChecked="LeftMenuTreeView_NodeChecked" >
            <DataBindings>
                <telerik:RadTreeNodeBinding DataMember="Node" CssClass="class" ImageUrlField="ImageUrl" ToolTip="ToolTip" CssClassField="cssAttrib" CheckableField="enablecheckbox"/>
            </DataBindings>
        </telerik:RadTreeView>
    </div>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="BodyContentPlaceHolder" runat="server">
    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
    <telerik:RadSkinManager ID="RadSkinManager1" runat="server">
    </telerik:RadSkinManager>
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />
    <div id="rside" runat="server">
        <telerik:RadMultiPage ID="MainMultiPage" Runat="server" SelectedIndex="0" Height="650px">
            <telerik:RadPageView runat="server" ID="GRSPageView" >
                <telerik:RadXmlHttpPanel ID="RadXmlHttpPanel1" runat="server">
                    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server"/>
                    <telerik:RadAjaxPanel runat="server" ClientEvents-OnResponseEnd="ResponseEnd">
                        <div id="RPanel" class="borded3">
                            <div class="otherDataHeading border2">
                                <b><span id="SP" onclick="ShowPanel();">GRS</span> <span id="HP" onclick="HidePanel()">Reports</span></b>
                            </div>
                            <div class="tabsContainer pxToRight">
                                <telerik:RadTabStrip ID="RadTabStripReports" runat="server" MultiPageID="RadMultiPageReports" SelectedIndex="0" Skin="WebBlue">
                                    <Tabs>
                                        <telerik:RadTab runat="server" Text="Filter" Selected="True">
                                        </telerik:RadTab>
                                    </Tabs>
                                </telerik:RadTabStrip>
                            </div>
                            <div id="RadMultiPageReportsContainer" class="componentsContainer">
                                <asp:Panel ID="Panel1" runat="server" CssClass="background1">
                                    <telerik:RadMultiPage ID="RadMultiPageReports" runat="server">
                                    <telerik:RadPageView ID="RadPageViewReports" runat="server" Selected="true">
                                        <asp:Panel ID="FilterPanel" runat="server">
                                            <div class="multiPageDivTab">
                                                <fieldset>
                                                    <legend><b>Consultant</b></legend>
                                                    <table id="FilterConsultant" class="checkboxesTable">
                                                        <tr>
                                                            <td style="min-width:145px;text-align:left;">
                                                                <asp:Label ID="Label1" runat="server" Text="Type word(s) to filter on: " CssClass="grsrep"></asp:Label>
                                                                <input id="ISMFilter" type="text" placeholder="Consultant name" />
                                                            </td>
                                                            <td style="text-align:right;min-width:100px;">
                                                                <asp:Label ID="Label2" runat="server" Text="Consultants type: " CssClass="grsrep"></asp:Label>
                                                            </td>
                                                            <td  style="text-align:right;">
                                                                <telerik:RadComboBox ID="ComboConsultants" runat="server" AutoPostBack="true" Skin="Windows7">
                                                                    <Items>
                                                                        <telerik:RadComboBoxItem runat="server" Text="All" Value="AllConsultants" />
                                                                        <telerik:RadComboBoxItem runat="server" Text="Endoscopist 1" Value="Endoscopist1" />
                                                                        <telerik:RadComboBoxItem runat="server" Text="Endoscopist 2" Value="Endoscopist2" />
                                                                        <telerik:RadComboBoxItem runat="server" Text="List Consultant" Value="ListConsultant" />
                                                                        <telerik:RadComboBoxItem runat="server" Text="Assistants or trainees" Value="Assistant" />
                                                                        <telerik:RadComboBoxItem runat="server" Text="Nurse 1" Value="Nurse1" />
                                                                        <telerik:RadComboBoxItem runat="server" Text="Nurse 2" Value="Nurse2" />
                                                                    </Items>
                                                                </telerik:RadComboBox>

                                                            </td>
                                                        </tr>
                                                    </table>
                                                    <telerik:RadAjaxPanel ID="RadAjaxPanel2" runat="server" height="200px" width="660px">
                                                        <div id="Consultants">
                                                            <div class="lb">
                                                                <telerik:RadListBox ID="RadListBox1" runat="server" Width="287px" Height="200px"
                                                    SelectionMode="Multiple" AllowTransfer="True" TransferToID="RadListBox2" EnableDragAndDrop="True" DataSourceID="SqlDSAllConsultants" DataKeyField="ReportID" DataTextField="Consultant" DataValueField="ReportID" ButtonSettings-VerticalAlign="Middle" >
                                                                </telerik:RadListBox>
                                                            </div>
                                                            <div class="lb">
                                                                <telerik:RadListBox ID="RadListBox2" runat="server" Width="287px" Height="200px"
                                                    SelectionMode="Multiple" AutoPostBackOnReorder="False" EnableDragAndDrop="True" 
                                                    DataKeyField="ReportID" DataTextField="Consultant" DataValueField="ReportID" DataSourceID="SqlDSSelectedConsultants" >
                                                                </telerik:RadListBox>
                                                            </div>
                                                        </div>
                                                    </telerik:RadAjaxPanel>
                                                    <div id="Together">
                                                        <table class="checkboxesTable">
                                                            <tr>
                                                                <td style="min-width:200px;"><b>
                                                                    <telerik:RadLabel ID="TogetherLabel" runat="server" CssClass="grsrep">
                                                                Together with these criteria
                                                                    </telerik:RadLabel>
                                                                    </b></td>
                                                                <td>
                                                                    <asp:TextBox runat="server" ID="tbGRSArray" Width="10" CssClass="secret">000000000000000000</asp:TextBox>
                                                                    <asp:CheckBox ID="cbHideSuppressed" Text="Hide suppressed endoscopists" runat="server" Skin="Web20" AutoPostBack="false" />
                                                                    <asp:TextBox runat="server" ID="SUID" Width="10" CssClass="secret"></asp:TextBox>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </div>
                                                </fieldset>
                                                <asp:ObjectDataSource ID="SqlDSAllConsultants" runat="server" SelectMethod="GetConsultantsListBox1" TypeName="UnisoftERS.Reporting">
                                                    <SelectParameters>
                                                        <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>
                                                <asp:ObjectDataSource ID="SqlDSSelectedConsultants" runat="server" SelectMethod="GetConsultantsListBox2" TypeName="UnisoftERS.Reporting">
                                                    <SelectParameters>
                                                        <asp:SessionParameter DefaultValue="NULL" Name="UserID" SessionField="PKUserID" Type="String" />
                                                    </SelectParameters>
                                                </asp:ObjectDataSource>
                                                <fieldset>
                                                    <legend>Dates</legend>
                                                    <table class="checkboxesTable">
                                                        <tr>
                                                            <td>From</td>
                                                            <td>To</td>
                                                            <td></td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <telerik:RadDatePicker ID="RDPFrom" runat="server">
                                                                </telerik:RadDatePicker>
                                                            </td>
                                                            <td style="text-align:right;">
                                                                <telerik:RadDatePicker ID="RDPTo" runat="server">
                                                                </telerik:RadDatePicker>
                                                            </td>
                                                            <td>
                                                                <div id="ApplyZone" onmousedown="InitTabs();">
                                                                    <telerik:RadButton ID="RadButtonFilter" runat="server" Text="Apply filter" Skin="Web20" OnClientClicking="ValidatingDates" OnClick="RadButtonFilter_Click" AutoPostBack="true" >
                                                                    </telerik:RadButton>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </table>
                                                    <asp:RequiredFieldValidator runat="server" ID="RequiredFieldValidatorFromDate" ControlToValidate="RDPFrom" ErrorMessage="Enter a date!" SetFocusOnError="True" ValidationGroup="FilterGroup" ForeColor="Red"></asp:RequiredFieldValidator>
                                                    <asp:RequiredFieldValidator runat="server" ID="RequiredfieldvalidatorToDate" ControlToValidate="RDPTo" ErrorMessage="Enter a date!" ValidationGroup="FilterGroup" ForeColor="Red"></asp:RequiredFieldValidator>
                                                    <asp:CompareValidator ID="dateCompareValidator" runat="server" ControlToValidate="RDPTo" ControlToCompare="RDPFrom" Operator="GreaterThan" ValidationGroup="FilterGroup" Type="Date" ErrorMessage="The second date must be after the first one." SetFocusOnError="True" ForeColor="Red"></asp:CompareValidator>
                                                </fieldset>
                                            </div>
                                        </asp:Panel>
                                        <div class="componentsContainer">
                                            <asp:Panel ID="MiniFilterPanel" runat="server">
                                                <div class="secret" id="RTSP">
                                                        <telerik:RadTabStrip ID="RadTabStripParameters" runat="server" MultiPageID="RadMultiPageParameters" SelectedIndex="0" Skin="WebBlue">
                                                        <Tabs>
                                                            <telerik:RadTab runat="server" Text="GRS A-1" PageViewID="GRSA01PV" ToolTip="GRS A-1 Diagnostic biopsies for diarrhoea">
                                                            </telerik:RadTab>
                                                            <telerik:RadTab runat="server" Text="GRS A-2" PageViewID="GRSA02PV" ToolTip="GRS A-2 Haemostasis after endoscopy therapy">
                                                            </telerik:RadTab>
                                                            <telerik:RadTab runat="server" Text="GRS A-3" PageViewID="GRSA03PV" ToolTip="GRS A-3 Stent and PEG/PEJ placement">
                                                            </telerik:RadTab>
                                                            <telerik:RadTab runat="server" Text="GRS A-4" PageViewID="GRSA04PV" ToolTip="GRS A-4 Use of reversing agent">
                                                            </telerik:RadTab>
                                                            <telerik:RadTab runat="server" Text="GRS A-5" PageViewID="GRSA05PV" ToolTip="GRS A-5 Assessment of sedation/comfort">
                                                            </telerik:RadTab>
                                                            <telerik:RadTab runat="server" Text="GRS B-1" PageViewID="GRSB01PV" ToolTip="GRS B-1 Analysis of colonic polyps/polypectomies">
                                                            </telerik:RadTab>
                                                            <telerik:RadTab runat="server" Text="GRS B-2" PageViewID="GRSB02PV" ToolTip="GRS B-2 Completion of intended therapeutic ERCP">
                                                            </telerik:RadTab>
                                                            <telerik:RadTab runat="server" Text="GRS B-3" PageViewID="GRSB03PV" ToolTip="GRS B-3 Decompression of obstructed ducts">
                                                            </telerik:RadTab>
                                                            <telerik:RadTab runat="server" Text="GRS B-4" PageViewID="GRSB04PV" ToolTip="GRS B-4 Repeat OGD for Gastric Ulcers">
                                                            </telerik:RadTab>
                                                            <telerik:RadTab runat="server" Text="GRS B-5" PageViewID="GRSB05PV" ToolTip="GRS B-5 Tattoing of small tumors and suspected malignant polyps">
                                                            </telerik:RadTab>
                                                            <telerik:RadTab runat="server" Text="GRS C-1" PageViewID="GRSC01PV" ToolTip="GRS C-1 Adenoma/polyp detection rate">
                                                            </telerik:RadTab>
                                                            <telerik:RadTab runat="server" Text="GRS C-2" PageViewID="GRSC02PV" ToolTip="GRS C-2 Colonoscopy completion summary">
                                                            </telerik:RadTab>
                                                            <telerik:RadTab runat="server" Text="GRS C-3" PageViewID="GRSC03PV" ToolTip="GRS C-3 Colonoscopy detailed failure report">
                                                            </telerik:RadTab>
                                                            <telerik:RadTab runat="server" Text="GRS C-4" PageViewID="GRSC04PV" ToolTip="GRS C-4 Analysis of colonoscopy bowel prep. (Boston)">
                                                            </telerik:RadTab>
                                                            <telerik:RadTab runat="server" Text="GRS C-5" PageViewID="GRSC05PV" ToolTip="GRS C-5 Analysis of colonoscopy bowel prep. (Standard)">
                                                            </telerik:RadTab>
                                                            <telerik:RadTab runat="server" Text="GRS C-6" PageViewID="GRSC06PV" ToolTip="">
                                                            </telerik:RadTab>
                                                            <telerik:RadTab runat="server" Text="GRS C-7" PageViewID="GRSC07PV" ToolTip="GRS C-7 Sedation and analgesia for all procedures">
                                                            </telerik:RadTab>
                                                            <telerik:RadTab runat="server" Text="GRS C-8" PageViewID="GRSC08PV" ToolTip="GRS C-8 successful Intubation and Completion of OGD">
                                                            </telerik:RadTab>
                                                        </Tabs>
                                                    </telerik:RadTabStrip>
                                                </div>
                                                <div>
                                                    <telerik:RadMultiPage ID="RadMultiPageParameters" runat="server" Height="150px" SelectedIndex="0">
                                                        <telerik:RadPageView ID="GRSA01PV" runat="server" visible="true">
                                                            <div class="multiPageDivTab">
                                                                <fieldset>
                                                                    <legend><b>Auditor's kit</b></legend>
                                                                    <p>
                                                        1) Select the corresponding tab for every particular filter conditions and then, click on the Filter button</p>
                                                                    <p>
                                                        2) New tabs will appear at the top of this page.</p>
                                                                    <p id="resetlocal">
                                                If you would like to clear your settings, click <b onclick="localStorage.clear();$('#resetlocal').hide();">here</b></p>
                                                                </fieldset>
                                                            </div>
                                                        </telerik:RadPageView>
                                                        <telerik:RadPageView ID="GRSA02PV" runat="server" >
                                                            <div class="multiPageDivTab">
                                                                <table class="checkboxesTable">
                                                                    <tr>
                                                                        <td>
                                                                            <fieldset class="otherDataFieldset2">
                                                                                <legend><b>Which endoscopist?</b></legend>
                                                                                <asp:CheckBox ID="cb1GRA2" runat="server" Text="As endoscopist 1" AutoPostBack="False" CssClass="dfltVal" Skin="Web20" />
                                                                                <asp:CheckBox ID="cb2GRA2" runat="server" Text="As endoscopist 2" AutoPostBack="False" CssClass="dfltVal" Skin="Web20" />
                                                                            </fieldset> </td>
                                                                        <td>
                                                                            <fieldset class="otherDataFieldset2">
                                                                                <legend><b>Procedure</b></legend>
                                                                                <asp:CheckBox ID="cb3GRA2" runat="server" Text="OGD" AutoPostBack="False" CssClass="dfltVal" Skin="Windows7" />
                                                                                <asp:CheckBox ID="cb4GRA2" runat="server" Text="Colon/Sigmoidoscopy" AutoPostBack="False" CssClass="dfltVal" Skin="Windows7" />
                                                                            </fieldset> </td>
                                                                    </tr>
                                                                </table>
                                                            </div>
                                                        </telerik:RadPageView>
                                                        <telerik:RadPageView ID="GRSA03PV" runat="server">
                                                            <div class="multiPageDivTab">
                                                                <table class="checkboxesTable">
                                                                    <tr>
                                                                        <td>
                                                                            <fieldset class="otherDataFieldset2">
                                                                                <legend><b>Age at procedure</b></legend>
                                                                                <asp:radioButtonList ID="radio1GRA3" runat="server" RepeatDirection="Horizontal" AutoPostBack="false" CssClass="grsrep">
                                                                                    <asp:ListItem Value="All" Selected="True">All</asp:ListItem>
                                                                                    <asp:ListItem Value="Under" >Under</asp:ListItem>
                                                                                    <asp:ListItem Value="Over" >Over</asp:ListItem>
                                                                                    <asp:ListItem Value="Between">Between</asp:ListItem>
                                                                                </asp:radioButtonList>
                                                                                <asp:TextBox id="FromAgeGRA3" text="0" maxlength="3" cssclass="grsrep number" runat="server"></asp:TextBox>
                                                                                <asp:Label ID="lbl1GRA3" runat="server" Text="Years and" CssClass="grsrep"></asp:Label>
                                                                                <asp:TextBox id="ToAgeGRA3" text="70" maxlength="3" cssclass="grsrep number" runat="server"></asp:TextBox>
                                                                                <asp:Label ID="lbl2GRA3" runat="server" Text="Years of age inclusive" CssClass="grsrep"></asp:Label>
                                                                            </fieldset> </td>
                                                                        <td rowspan="3" style="vertical-align:top;">
                                                                            <fieldset class="otherDataFieldset2">
                                                                                <legend><b>Age at procedure</b></legend>
                                                                                <asp:CheckBox ID="cb1GRA3" runat="server" Text="oesophageal stent (following stricture)" AutoPostBack="False" CssClass="dfltVal" />
                                                                                <br />
                                                                                <asp:CheckBox ID="cb2GRA3" runat="server" Text="duodenal stent" AutoPostBack="False" CssClass="dfltVal" />
                                                                                <br />
                                                                                <asp:CheckBox ID="cb3GRA3" runat="server" Text="colonic stent" AutoPostBack="False" CssClass="dfltVal" />
                                                                                <br />
                                                                                <asp:CheckBox ID="cb4GRA3" runat="server" Text="percutaneous endoscopic gastrostomy (PEG)" AutoPostBack="False" CssClass="dfltVal" />
                                                                                <br />
                                                                                <asp:CheckBox ID="cb5GRA3" runat="server" Text="percutaneous endoscopic jejunostomy (PEJ)" AutoPostBack="False" CssClass="dfltVal" />
                                                                            </fieldset> </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td>
                                                                            <fieldset>
                                                                                <legend>Summary</legend>
                                                                                <asp:radioButtonList ID="radio2GRA3" runat="server" RepeatDirection="Horizontal" AutoPostBack="false" CssClass="grsrep">
                                                                                    <asp:ListItem Value="Count" Selected="True">Count of procedures</asp:ListItem>
                                                                                    <asp:ListItem Value="List">List of Patients involved</asp:ListItem>
                                                                                </asp:radioButtonList>
                                                                                <asp:CheckBox ID="cb6GRA3" runat="server" Text="Include endoscopy unit as a whole" AutoPostBack="False" CssClass="dfltVal" />
                                                                            </fieldset> </td>
                                                                    </tr>
                                                                </table>
                                                            </div>
                                                        </telerik:RadPageView>
                                                        <telerik:RadPageView ID="GRSA04PV" runat="server">
                                                            <div class="multiPageDivTab">
                                                                <table class="checkboxesTable">
                                                                    <tr>
                                                                        <td>
                                                                            <fieldset class="otherDataFieldset2">
                                                                                <legend><b>Summary</b></legend>
                                                                                <asp:CheckBox ID="cb1GRA4" runat="server" Text="Include summary" AutoPostBack="False" CssClass="dfltVal" />
                                                                                <asp:CheckBox ID="cb2GRA4" runat="server" Text="Include list of patients and doses" AutoPostBack="False" CssClass="dfltVal" />
                                                                            </fieldset> </td>
                                                                    </tr>
                                                                </table>
                                                            </div>
                                                        </telerik:RadPageView>
                                                        <telerik:RadPageView ID="GRSA05PV" runat="server">
                                                            <div class="multiPageDivTab">
                                                                <table class="checkboxesTable">
                                                                    <tr>
                                                                        <td>
                                                                            <fieldset class="otherDataFieldset2">
                                                                                <legend><b>Assessment of sedation / comfort</b></legend>
                                                                                <asp:CheckBox ID="cb1GRA5" runat="server" Text="Include endoscopy unit as a whole" AutoPostBack="False" CssClass="dfltVal" />
                                                                                <br />
                                                                                <asp:CheckBox ID="cb2GRA5" runat="server" Text="List of procedures where nurses assessment of patients discomfort during the procedure scored greater than or equal to 4" AutoPostBack="False" CssClass="dfltVal" />
                                                                            </fieldset> </td>
                                                                    </tr>
                                                                </table>
                                                            </div>
                                                        </telerik:RadPageView>
                                                        <telerik:RadPageView ID="GRSB01PV" runat="server">
                                                            <div class="multiPageDivTab">
                                                                <table class="checkboxesTable">
                                                                    <tr>
                                                                        <td style="vertical-align:top;">
                                                                            <fieldset class="otherDataFieldset2">
                                                                                <legend><b>Age at procedure</b></legend>
                                                                                <asp:radioButtonList ID="radio1GRB1" runat="server" RepeatDirection="Horizontal" AutoPostBack="false" CssClass="grsrep">
                                                                                    <asp:ListItem Value="All" Selected="True">All</asp:ListItem>
                                                                                    <asp:ListItem Value="Under">Under</asp:ListItem>
                                                                                    <asp:ListItem Value="Over">Over</asp:ListItem>
                                                                                    <asp:ListItem Value="Between">Between</asp:ListItem>
                                                                                </asp:radioButtonList>
                                                                                <asp:TextBox id="FromAgeGRB1" text="0" maxlength="3" cssclass="grsrep number" runat="server"></asp:TextBox>
                                                                                <asp:Label ID="lbl1GRB1" runat="server" Text="Years and" CssClass="grsrep"></asp:Label>
                                                                                <asp:TextBox id="ToAgeGRB1" text="70" maxlength="3" cssclass="grsrep number" runat="server"></asp:TextBox>
                                                                                <asp:Label ID="lbl2GRB1" runat="server" Text="Years of age inclusive" CssClass="grsrep"></asp:Label>
                                                                            </fieldset> </td>
                                                                        <td>
                                                                            <fieldset class="otherDataFieldset2">
                                                                                <legend><b>greater than</b></legend>
                                                                                <table class="condensed">
                                                                                    <tr>
                                                                                        <td></td>
                                                                                        <td><span class="grsrep">greater than</span></td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <td>
                                                                                            <asp:CheckBox ID="cb1GRB1" runat="server" Text="Sessile" AutoPostBack="False" CssClass="dfltVal" />
                                                                                        </td>
                                                                                        <td>
                                                                                            <input id="in1GRB1" runat="server" type="number" value="0" min="0" max="200" step="1" size="3" maxlength="3" class="grsrep" />
                                                                                            <span class="grsrep">mm</span></td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <td>
                                                                                            <asp:CheckBox ID="cb2GRB1" runat="server" Text="Pedunculated" AutoPostBack="False" CssClass="dfltVal" />
                                                                                        </td>
                                                                                        <td>
                                                                                            <input runat="server" id="in2GRB1" type="number" value="0" min="0" max="200" step="1" size="3" maxlength="3" class="grsrep" />
                                                                                            <span class="grsrep">mm</span></td>
                                                                                    </tr>
                                                                                    <tr>
                                                                                        <td>
                                                                                            <asp:CheckBox ID="cb3GRB1" runat="server" Text="Pseudopolyp" AutoPostBack="False" CssClass="dfltVal" />
                                                                                        </td>
                                                                                        <td>
                                                                                            <input id="in3GRB1" runat="server" type="number" value="0" min="0" max="200" step="1" size="3" maxlength="3" class="grsrep" />
                                                                                            <span class="grsrep">mm</span></td>
                                                                                    </tr>
                                                                                </table>
                                                                            </fieldset> </td>
                                                                    </tr>
                                                                </table>
                                                            </div>
                                                        </telerik:RadPageView>
                                                        <telerik:RadPageView ID="GRSB02PV" runat="server">
                                                            <div class="multiPageDivTab">
                                                                <table class="checkboxesTable">
                                                                    <tr>
                                                                        <td>
                                                                            <fieldset class="otherDataFieldset2">
                                                                                <legend><b>Age at procedure</b></legend>
                                                                                <asp:radioButtonList ID="radio1GRB2" runat="server" RepeatDirection="Horizontal" AutoPostBack="false" CssClass="grsrep">
                                                                                    <asp:ListItem Value="All" Selected="True">All</asp:ListItem>
                                                                                    <asp:ListItem Value="Under">Under</asp:ListItem>
                                                                                    <asp:ListItem Value="Over">Over</asp:ListItem>
                                                                                    <asp:ListItem Value="Between">Between</asp:ListItem>
                                                                                </asp:radioButtonList>
                                                                                <asp:TextBox id="FromAgeGRB2" text="0" maxlength="3" cssclass="grsrep number" runat="server"></asp:TextBox>
                                                                                <asp:Label ID="lbl1GRB2" runat="server" Text="Years and" CssClass="grsrep"></asp:Label>
                                                                                <asp:TextBox id="ToAgeGRB2" text="70" maxlength="3" cssclass="grsrep number" runat="server"></asp:TextBox>
                                                                                <asp:Label ID="lbl2GRB2" runat="server" Text="Years of age inclusive" CssClass="grsrep"></asp:Label>
                                                                            </fieldset> </td>
                                                                        <td style="vertical-align:top;">
                                                                            <fieldset class="otherDataFieldset2">
                                                                                <legend><b>Which endoscopist?</b></legend>
                                                                                <asp:CheckBox ID="cb1GRB2" runat="server" Text="As endoscopist 1" AutoPostBack="False" CssClass="dfltVal" />
                                                                                <asp:CheckBox ID="cb2GRB2" runat="server" Text="As endoscopist 2" AutoPostBack="False" CssClass="dfltVal" />
                                                                            </fieldset> </td>
                                                                    </tr>
                                                                </table>
                                                            </div>
                                                        </telerik:RadPageView>
                                                        <telerik:RadPageView ID="GRSB03PV" runat="server">
                                                            <div class="multiPageDivTab">
                                                                <table class="checkboxesTable">
                                                                    <tr>
                                                                        <td style="vertical-align:top;">
                                                                            <fieldset class="otherDataFieldset2">
                                                                                <legend><b>Age at procedure</b></legend>
                                                                                <asp:radioButtonList ID="radio1GRB3" runat="server" RepeatDirection="Horizontal" AutoPostBack="false" CssClass="grsrep">
                                                                                    <asp:ListItem Value="All" Selected="True">All</asp:ListItem>
                                                                                    <asp:ListItem Value="Under" >Under</asp:ListItem>
                                                                                    <asp:ListItem Value="Over" >Over</asp:ListItem>
                                                                                    <asp:ListItem Value="Between">Between</asp:ListItem>
                                                                                </asp:radioButtonList>
                                                                                <asp:TextBox id="FromAgeGRB3" text="0" maxlength="3" cssclass="grsrep number" runat="server"></asp:TextBox>
                                                                                <asp:Label ID="lbl1GRB3" runat="server" Text="Years and" CssClass="grsrep"></asp:Label>
                                                                                <asp:TextBox id="ToAgeGRB3" text="70" maxlength="3" cssclass="grsrep number" runat="server"></asp:TextBox>
                                                                                <asp:Label ID="lbl2GRB3" runat="server" Text="Years of age inclusive" CssClass="grsrep"></asp:Label>
                                                                            </fieldset> </td>
                                                                        <td>
                                                                            <fieldset class="otherDataFieldset2">
                                                                                <legend><b>Which endoscopist?</b></legend>
                                                                                <asp:CheckBox ID="cb1GRB3" runat="server" Text="As endoscopist 1" AutoPostBack="False" CssClass="dfltVal" />
                                                                                <asp:CheckBox ID="cb2GRB3" runat="server" Text="As endoscopist 2" AutoPostBack="False" CssClass="dfltVal" />
                                                                            </fieldset>
                                                                            <fieldset class="otherDataFieldset2">
                                                                                <legend><b>Summary</b></legend>
                                                                                <asp:CheckBox ID="cb3GRB3" runat="server" Text="Include endoscopy unit as a whole" AutoPostBack="False" CssClass="dfltVal" />
                                                                            </fieldset> </td>
                                                                    </tr>
                                                                </table>
                                                            </div>
                                                        </telerik:RadPageView>
                                                        <telerik:RadPageView ID="GRSB04PV" runat="server">
                                                            <div class="multiPageDivTab">
                                                                <fieldset class="otherDataFieldset2">
                                                                    <legend><b>Scope</b></legend>
                                                                    <asp:Label ID="Label3" runat="server" Text="Covering the whole database" CssClass="grsrep"></asp:Label>
                                                                </fieldset>
                                                            </div>
                                                        </telerik:RadPageView>
                                                        <telerik:RadPageView ID="GRSB05PV" runat="server">
                                                            <div class="multiPageDivTab">
                                                                <table class="condensed">
                                                                    <tr>
                                                                        <td>
                                                                            <table class="condensed">
                                                                                <tr>
                                                                                    <td>
                                                                                        <asp:CheckBox ID="cb1GRB5" runat="server" Text="As endoscopist 1" AutoPostBack="False" CssClass="dfltVal" />
                                                                                        <asp:CheckBox ID="cb2GRB5" runat="server" Text="As endoscopist 2" AutoPostBack="False" CssClass="dfltVal" />
                                                                                    </td>
                                                                                </tr>
                                                                                <tr>
                                                                                    <td>
                                                                                        <fieldset class="otherDataFieldset2">
                                                                                            <legend><b>Age at procedure</b></legend>
                                                                                            <asp:radioButtonList ID="radio1GRB5" runat="server" RepeatDirection="Horizontal" AutoPostBack="false" CssClass="grsrep">
                                                                                                <asp:ListItem Value="All" Selected="True">All</asp:ListItem>
                                                                                                <asp:ListItem Value="Under">Under</asp:ListItem>
                                                                                                <asp:ListItem Value="Over">Over</asp:ListItem>
                                                                                                <asp:ListItem Value="Between">Between</asp:ListItem>
                                                                                            </asp:radioButtonList>
                                                                                            <asp:TextBox id="FromAgeGRB5" text="0" maxlength="3" cssclass="grsrep number" runat="server"></asp:TextBox>
                                                                                            <asp:Label ID="lbl1GRB5" runat="server" Text="Years and" CssClass="grsrep"></asp:Label>
                                                                                            <asp:TextBox id="ToAgeGRB5" text="70" maxlength="3" cssclass="grsrep number" runat="server"></asp:TextBox>
                                                                                            <asp:Label ID="lbl2GRB5" runat="server" Text="Years of age inclusive" CssClass="grsrep"></asp:Label>
                                                                                        </fieldset> </td>
                                                                                </tr>
                                                                            </table>
                                                                        </td>
                                                                        <td>
                                                                            <fieldset class="otherDataFieldset2">
                                                                                <legend><b>Polyps and tumours</b></legend>
                                                                                <table class="checkboxesTable">
                                                                                    <tr>
                                                                                        <td>
                                                                                            <table class="condensed" style="min-width:170px;">
                                                                                                <tr>
                                                                                                    <td></td>
                                                                                                    <td style="text-align:center;"><span class="grsrep">&gt;</span></td>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <td>
                                                                                                        <asp:CheckBox ID="cb1Tumour" runat="server" Text="Sessile polyp" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                    </td>
                                                                                                    <td>
                                                                                                        <input id="in1GB5" runat="server" type="number" value="20" min="0" max="999" step="1" size="2" maxlength="3" class="grsrep" />
                                                                                                    </td>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <td>
                                                                                                        <asp:CheckBox ID="cb2Tumour" runat="server" Text="Pedunculated polyp" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                    </td>
                                                                                                    <td>
                                                                                                        <input id="in2GB5" runat="server" type="number" value="20" min="0" max="999" step="1" size="2" maxlength="3" class="grsrep" />
                                                                                                    </td>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <td>
                                                                                                        <asp:CheckBox ID="cb3Tumour" runat="server" Text="Submucosal tumour" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                    </td>
                                                                                                    <td>
                                                                                                        <input id="in3GB5" runat="server" type="number" value="20" min="0" max="999" step="1" size="2" maxlength="3" class="grsrep" />
                                                                                                    </td>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <td>
                                                                                                        <asp:CheckBox ID="cb4Tumour" runat="server" Text="Villous tumour" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                    </td>
                                                                                                    <td>
                                                                                                        <input id="in4GB5" runat="server" type="number" value="20" min="0" max="999" step="1" size="2" maxlength="3" class="grsrep" />
                                                                                                    </td>
                                                                                                </tr>
                                                                                            </table>
                                                                                        </td>
                                                                                        <td>
                                                                                            <table class="condensed" style="min-width:160px;">
                                                                                                <tr>
                                                                                                    <td></td>
                                                                                                    <td style="text-align:center;"><span class="grsrep">&gt;</span></td>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <td>
                                                                                                        <asp:CheckBox ID="cb5Tumour" runat="server" Text="Ulcerative tumour" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                    </td>
                                                                                                    <td>
                                                                                                        <input id="in5GB5" runat="server" type="number" value="20" min="0" max="999" step="1" size="2" maxlength="3" class="grsrep" />
                                                                                                    </td>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <td>
                                                                                                        <asp:CheckBox ID="cb6Tumour" runat="server" Text="Stricturing tumour" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                    </td>
                                                                                                    <td>
                                                                                                        <input id="in6GB5" runat="server" type="number" value="20" min="0" max="999" step="1" size="2" maxlength="3" class="grsrep" />
                                                                                                    </td>
                                                                                                </tr>
                                                                                                <tr>
                                                                                                    <td>
                                                                                                        <asp:CheckBox ID="cb7Tumour" runat="server" Text="Polypoidal tumour" AutoPostBack="False" CssClass="dfltVal" />
                                                                                                    </td>
                                                                                                    <td>
                                                                                                        <input id="in7GB5" runat="server" type="number" value="20" min="0" max="999" step="1" size="2" maxlength="3" class="grsrep" />
                                                                                                    </td>
                                                                                                </tr>
                                                                                            </table>
                                                                                        </td>
                                                                                    </tr>
                                                                                </table>
                                                                            </fieldset> </td>
                                                                    </tr>
                                                                </table>
                                                            </div>
                                                        </telerik:RadPageView>
                                                        <telerik:RadPageView ID="GRSC01PV" runat="server">
                                                            <div class="multiPageDivTab">
                                                                <table class="checkboxesTable">
                                                                    <tr>
                                                                        <td>
                                                                            <fieldset class="otherDataFieldset2">
                                                                                <legend><b>Which endoscopist?</b></legend>
                                                                                <asp:CheckBox ID="cb1GRC1" runat="server" Text="As endoscopist 1" AutoPostBack="False" CssClass="dfltVal" />
                                                                                <asp:CheckBox ID="cb2GRC1" runat="server" Text="As endoscopist 2" AutoPostBack="False" CssClass="dfltVal" />
                                                                            </fieldset> </td>
                                                                        <td>
                                                                            <fieldset class="otherDataFieldset2">
                                                                                <legend><b>Procedure</b></legend>
                                                                                <asp:radioButtonList ID="radio1GRC1" runat="server" RepeatDirection="Horizontal" AutoPostBack="false" CssClass="grsrep">
                                                                                    <asp:ListItem Value="COL" Selected="True">Colonoscopy</asp:ListItem>
                                                                                    <asp:ListItem Value="SIG">Sigmoidoscopy</asp:ListItem>
                                                                                </asp:radioButtonList>
                                                                            </fieldset> </td>
                                                                    </tr>
                                                                </table>
                                                            </div>
                                                        </telerik:RadPageView>
                                                        <telerik:RadPageView ID="GRSC02PV" runat="server">
                                                            <div class="multiPageDivTab">
                                                                <table class="checkboxesTable">
                                                                    <tr>
                                                                        <td>
                                                                            <fieldset class="otherDataFieldset2">
                                                                                <legend><b>Which endoscopist?</b></legend>
                                                                                <asp:CheckBox ID="cb1GRC2" runat="server" Text="As endoscopist 1" AutoPostBack="False" CssClass="dfltVal" />
                                                                                <asp:CheckBox ID="cb2GRC2" runat="server" Text="As endoscopist 2" AutoPostBack="False" CssClass="dfltVal" />
                                                                            </fieldset> </td>
                                                                        <td>
                                                                            <fieldset class="otherDataFieldset2">
                                                                                <legend><b>Summary</b></legend>
                                                                                <asp:CheckBox ID="cb3GRC2" runat="server" Text="Include endoscopy unit as a whole" AutoPostBack="False" CssClass="dfltVal" />
                                                                            </fieldset> </td>
                                                                    </tr>
                                                                </table>
                                                            </div>
                                                        </telerik:RadPageView>
                                                        <telerik:RadPageView ID="GRSC03PV" runat="server">
                                                            <div class="multiPageDivTab">
                                                                <table class="checkboxesTable">
                                                                    <tr>
                                                                        <td>
                                                                            <fieldset class="otherDataFieldset2">
                                                                                <legend><b>Which endoscopist?</b></legend>
                                                                                <asp:CheckBox ID="cb1GRC3" runat="server" Text="As endoscopist 1" AutoPostBack="False" CssClass="dfltVal" />
                                                                                <asp:CheckBox ID="cb2GRC3" runat="server" Text="As endoscopist 2" AutoPostBack="False" CssClass="dfltVal" />
                                                                            </fieldset> </td>
                                                                        <td>
                                                                            <fieldset class="otherDataFieldset2">
                                                                                <legend><b>Procedure</b></legend>
                                                                                <asp:radioButtonList ID="radio1GRC3" runat="server" RepeatDirection="Horizontal" AutoPostBack="false" CssClass="grsrep">
                                                                                    <asp:ListItem Value="COL" Selected="True">Colonoscopy</asp:ListItem>
                                                                                    <asp:ListItem Value="SIG">Sigmoidoscopy</asp:ListItem>
                                                                                </asp:radioButtonList>
                                                                            </fieldset> </td>
                                                                    </tr>
                                                                    <tr>
                                                                        <td rowspan="2">
                                                                            <fieldset class="otherDataFieldset2">
                                                                                <legend><b>Additional parameters</b></legend>
                                                                                <asp:CheckBox ID="cb3GRC3" runat="server" Text="Include perioperative complications" AutoPostBack="False" CssClass="dfltVal" />
                                                                                <asp:CheckBox ID="cb4GRC3" runat="server" Text="Include reversal agents" AutoPostBack="False" CssClass="dfltVal" />
                                                                            </fieldset> </td>
                                                                    </tr>
                                                                </table>
                                                            </div>
                                                        </telerik:RadPageView>
                                                        <telerik:RadPageView ID="GRSC04PV" runat="server">
                                                            <div class="multiPageDivTab">
                                                                <table class="checkboxesTable">
                                                                    <tr>
                                                                        <td>
                                                                            <fieldset class="otherDataFieldset2">
                                                                                <legend><b>Procedure</b></legend>
                                                                                <asp:radioButtonList ID="radio1GRC4" runat="server" RepeatDirection="Horizontal" AutoPostBack="false" CssClass="grsrep">
                                                                                    <asp:ListItem Value="COL" Selected="True">Colonoscopy</asp:ListItem>
                                                                                    <asp:ListItem Value="SIG">Sigmoidoscopy</asp:ListItem>
                                                                                </asp:radioButtonList>
                                                                            </fieldset> </td>
                                                                    </tr>
                                                                </table>
                                                            </div>
                                                        </telerik:RadPageView>
                                                        <telerik:RadPageView ID="GRSC05PV" runat="server">
                                                            <div class="multiPageDivTab">
                                                                <table class="checkboxesTable">
                                                                    <tr>
                                                                        <td>
                                                                            <fieldset class="otherDataFieldset2">
                                                                                <legend><b>Procedure</b></legend>
                                                                                <asp:radioButtonList ID="radio1GRC5" runat="server" RepeatDirection="Horizontal" AutoPostBack="false" CssClass="grsrep">
                                                                                    <asp:ListItem Value="COL" Selected="True">Colonoscopy</asp:ListItem>
                                                                                    <asp:ListItem Value="SIG">Sigmoidoscopy</asp:ListItem>
                                                                                </asp:radioButtonList>
                                                                            </fieldset> </td>
                                                                    </tr>
                                                                </table>
                                                            </div>
                                                        </telerik:RadPageView>
                                                        <telerik:RadPageView ID="GRSC06PV" runat="server">
                                                            <div class="multiPageDivTab">
                                                                <table class="checkboxesTable">
                                                                    <tr>
                                                                        <td>
                                                                            <fieldset class="otherDataFieldset2">
                                                                                <legend><b>Procedure</b></legend>
                                                                                <asp:radioButtonList ID="radio1GRC6" runat="server" RepeatDirection="Horizontal" AutoPostBack="false" CssClass="grsrep">
                                                                                    <asp:ListItem Value="COL" Selected="True">Colonoscopy</asp:ListItem>
                                                                                </asp:radioButtonList>
                                                                            </fieldset> </td>
                                                                    </tr>
                                                                </table>
                                                            </div>
                                                        </telerik:RadPageView>
                                                        <telerik:RadPageView ID="GRSC07PV" runat="server">
                                                            <div class="multiPageDivTab">
                                                                <table class="adjusted">
                                                                    <tr>
                                                                        <td style="vertical-align:top;">
                                                                            <fieldset class="otherDataFieldset2">
                                                                                <legend><b>Output As</b></legend>
                                                                                <asp:radioButtonList ID="radio3GRC7" runat="server" RepeatDirection="Horizontal" AutoPostBack="false" CssClass="grsrep" >
                                                                                    <asp:ListItem Value="1" Selected="True">List of patients</asp:ListItem>
                                                                                    <asp:ListItem Value="2">Mean dosage values</asp:ListItem>
                                                                                    <asp:ListItem Value="3">Median dosage values</asp:ListItem>
                                                                                </asp:radioButtonList>
                                                                                <asp:CheckBox ID="cb3GRC7" runat="server" Text="" AutoPostBack="False" CssClass="grsrep" />
                                                                                <telerik:RadLabel ID="lbl3GRC7" runat="server" Text="Include blanks as Zeroes" CssClass="grsrep">
                                                                                </telerik:RadLabel>
                                                                            </fieldset> </td>
                                                                        <td style="vertical-align:top;">
                                                                            <fieldset class="otherDataFieldset2">
                                                                                <legend><b>Age at procedure</b></legend>
                                                                                <asp:radioButtonList ID="radio1GRC7" runat="server" RepeatDirection="Horizontal" AutoPostBack="false" CssClass="grsrep">
                                                                                    <asp:ListItem Value="All" Selected="True">All</asp:ListItem>
                                                                                    <asp:ListItem Value="Under" >Under</asp:ListItem>
                                                                                    <asp:ListItem Value="Over" >Over</asp:ListItem>
                                                                                    <asp:ListItem Value="Between">Between</asp:ListItem>
                                                                                </asp:radioButtonList>
                                                                                <asp:TextBox id="FromAgeGRC7" text="0" maxlength="3" cssclass="grsrep number required" runat="server"></asp:TextBox>
                                                                                <asp:RequiredFieldValidator runat="server" ID="FromAgeGRC7FV" ControlToValidate="FromAgeGRC7" Display="Dynamic" ErrorMessage="Value is required" ValidationGroup="FilterGroup"></asp:RequiredFieldValidator>
                                                                                <asp:Label ID="lbl1GRC7" runat="server" Text="Years and" CssClass="grsrep"></asp:Label>
                                                                                <asp:TextBox id="ToAgeGRC7" text="70" maxlength="3" cssclass="grsrep number required" runat="server">70</asp:TextBox>
                                                                                <asp:RequiredFieldValidator runat="server" ID="ToAgeGRC7FV" ControlToValidate="ToAgeGRC7" Display="Dynamic" ErrorMessage="Value is required" ValidationGroup="FilterGroup"></asp:RequiredFieldValidator>
                                                                                <asp:Label ID="lbl2GRC7" runat="server" Text="Years of age inclusive" CssClass="grsrep"></asp:Label>
                                                                            </fieldset>
                                                                            <fieldset class="otherDataFieldset2">
                                                                                <legend><b>Procedure</b></legend>
                                                                                <asp:radioButtonList ID="radio2GRC7" runat="server" RepeatDirection="Horizontal" AutoPostBack="false" CssClass="grsrep">
                                                                                    <asp:ListItem Value="OGD" Selected="True">OGD</asp:ListItem>
                                                                                    <asp:ListItem Value="ERC">ERCP</asp:ListItem>
                                                                                    <asp:ListItem Value="PRO">Proct.</asp:ListItem>
                                                                                    <asp:ListItem Value="COL">Colon.</asp:ListItem>
                                                                                    <asp:ListItem Value="SIG">Sigmoid.</asp:ListItem>
                                                                                </asp:radioButtonList>
                                                                            </fieldset> </td>
                                                                    </tr>
                                                                </table>
                                                            </div>
                                                        </telerik:RadPageView>
                                                        <telerik:RadPageView ID="GRSC08PV" runat="server">
                                                            <div class="multiPageDivTab">
                                                                <fieldset class="otherDataFieldset2">
                                                                    <legend><b>Summary</b></legend>
                                                                    <asp:CheckBox ID="cb1GRC8" runat="server" Text="Include endoscopy unit as a whole" AutoPostBack="False" CssClass="dfltVal" />
                                                                    <asp:CheckBox ID="cb2GRC8" runat="server" Text="List patients where not completed" AutoPostBack="False" CssClass="dfltVal" />
                                                                </fieldset>
                                                            </div>
                                                        </telerik:RadPageView>
                                                    </telerik:RadMultiPage>
                                                </div>
                                            </asp:Panel>
                                        </div>
                                    </telerik:RadPageView>
                                </telerik:RadMultiPage>
                                </asp:Panel>
                            </div>
                        </div>
                    </telerik:RadAjaxPanel>
                </telerik:RadXmlHttpPanel>
            </telerik:RadPageView>
            <telerik:RadPageView runat="server" ID="MiscPageView" Height="700px">
                <div class="" id="DeploySite" runat="server">
                    <div class="" id="ReportURL" runat="server">
                        <iframe src="JAGGRS.aspx" runat="server" class="if"></iframe>
                    </div>
                </div>
            </telerik:RadPageView>
        </telerik:RadMultiPage>
    </div>
<script type="text/javascript">

    $("#RTSP").hide();
    $(document).load(function () {
    });
    $(document).ready(function () {
        var availableUserList = $find("<%=RadListBox1.ClientID%>");
        $("#ISMFilter").keyup(function () {
            var item;
            var search;
            search = $(this).val();
            if (search.length > 1) {
                for (var i = 0; i < availableUserList._children.get_count() ; i++) {
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
        $("#RadButtonFilter").click(function (e, args) {
            var currentLoadingPanel = $find("<%= RadAjaxLoadingPanel1.ClientID%>");
            var currentUpdatedControl = "<%= Panel1.ClientID%>";
            currentLoadingPanel.show(currentUpdatedControl);
        });

        $("#GRSA01PV").hide();
        $("#GRSA02PV").hide();
        $("#GRSA03PV").hide();
        $("#GRSA04PV").hide();
        $("#GRSA05PV").hide();
        $("#GRSB01PV").hide();
        $("#GRSB02PV").hide();
        $("#GRSB03PV").hide();
        $("#GRSB04PV").hide();
        $("#GRSB05PV").hide();
        $("#GRSC01PV").hide();
        $("#GRSC02PV").hide();
        $("#GRSC03PV").hide();
        $("#GRSC04PV").hide();
        $("#GRSC05PV").hide();
        $("#GRSC06PV").hide();
        $("#GRSC07PV").hide();
        $("#GRSC08PV").hide();
        $("#BodyContentPlaceHolder_in1GRB1").change(function () { localStorage.setItem("in1GRB1", $("#BodyContentPlaceHolder_in1GRB1").val()); });
        $("#BodyContentPlaceHolder_in2GRB1").change(function () { localStorage.setItem("in2GRB1", $("#BodyContentPlaceHolder_in2GRB1").val()); });
        $("#BodyContentPlaceHolder_in3GRB1").change(function () { localStorage.setItem("in3GRB1", $("#BodyContentPlaceHolder_in3GRB1").val()); });

        $("#BodyContentPlaceHolder_in1GB5").change(function () { localStorage.setItem("in1GB5", $("#BodyContentPlaceHolder_in1GB5").val()); });
        $("#BodyContentPlaceHolder_in2GB5").change(function () { localStorage.setItem("in2GB5", $("#BodyContentPlaceHolder_in2GB5").val()); });
        $("#BodyContentPlaceHolder_in3GB5").change(function () { localStorage.setItem("in3GB5", $("#BodyContentPlaceHolder_in3GB5").val()); });
        $("#BodyContentPlaceHolder_in4GB5").change(function () { localStorage.setItem("in4GB5", $("#BodyContentPlaceHolder_in4GB5").val()); });
        $("#BodyContentPlaceHolder_in5GB5").change(function () { localStorage.setItem("in5GB5", $("#BodyContentPlaceHolder_in5GB5").val()); });
        $("#BodyContentPlaceHolder_in6GB5").change(function () { localStorage.setItem("in6GB5", $("#BodyContentPlaceHolder_in6GB5").val()); });
        $("#BodyContentPlaceHolder_in7GB5").change(function () { localStorage.setItem("in7GB5", $("#BodyContentPlaceHolder_in7GB5").val()); });

        $("#BodyContentPlaceHolder_radio1GRA3").change(function () {
            localStorage.setItem("radio1GRA3", $("#BodyContentPlaceHolder_radio1GRA3 :checked").val());
            if ($("#BodyContentPlaceHolder_radio1GRA3 :checked").val() == "All") {
                $("#BodyContentPlaceHolder_FromAgeGRA3").hide();
                $("#BodyContentPlaceHolder_ToAgeGRA3").hide();
                $("#BodyContentPlaceHolder_lbl1GRA3").text("(All age groups)");
                $("#BodyContentPlaceHolder_lbl1GRA3").show();
                $("#BodyContentPlaceHolder_lbl2GRA3").text(" ");
                $("#BodyContentPlaceHolder_lbl2GRA3").hide();
            }
            if ($("#BodyContentPlaceHolder_radio1GRA3 :checked").val() == "Under") {
                $("#BodyContentPlaceHolder_FromAgeGRA3").hide();
                $("#BodyContentPlaceHolder_ToAgeGRA3").show();
                $("#BodyContentPlaceHolder_lbl1GRA3").text(" ");
                $("#BodyContentPlaceHolder_lbl1GRA3").hide();
                $("#BodyContentPlaceHolder_lbl2GRA3").text("years of age");
                $("#BodyContentPlaceHolder_lbl2GRA3").show();
            }
            if ($("#BodyContentPlaceHolder_radio1GRA3 :checked").val() == "Over") {
                $("#BodyContentPlaceHolder_FromAgeGRA3").show();
                $("#BodyContentPlaceHolder_ToAgeGRA3").hide();
                $("#BodyContentPlaceHolder_lbl1GRA3").text("years of age");
                $("#BodyContentPlaceHolder_lbl1GRA3").show();
                $("#BodyContentPlaceHolder_lbl2GRA3").text(" ");
                $("#BodyContentPlaceHolder_lbl2GRA3").hide();
            }
            if ($("#BodyContentPlaceHolder_radio1GRA3 :checked").val() == "Between") {
                $("#BodyContentPlaceHolder_FromAgeGRA3").show();
                $("#BodyContentPlaceHolder_ToAgeGRA3").show();
                $("#BodyContentPlaceHolder_lbl1GRA3").text("years and");
                $("#BodyContentPlaceHolder_lbl1GRA3").show();
                $("#BodyContentPlaceHolder_lbl2GRA3").text("years of age inclusive");
                $("#BodyContentPlaceHolder_lbl2GRA3").show();
            }
            if ($("#BodyContentPlaceHolder_radio1GRB2 :checked").val() == "Between") {
                $("#BodyContentPlaceHolder_FromAgeGRB2").show();
                $("#BodyContentPlaceHolder_ToAgeGRB2").show();
                $("#BodyContentPlaceHolder_lbl1GRB2").text("years and");
                $("#BodyContentPlaceHolder_lbl1GRB2").show();
                $("#BodyContentPlaceHolder_lbl2GRB2").text("years of age inclusive");
                $("#BodyContentPlaceHolder_lbl2GRB2").show();
            }
            if ($("#BodyContentPlaceHolder_radio1GRB3 :checked").val() == "Between") {
                $("#BodyContentPlaceHolder_FromAgeGRB3").show();
                $("#BodyContentPlaceHolder_ToAgeGRB3").show();
                $("#BodyContentPlaceHolder_lbl1GRB3").text("years and");
                $("#BodyContentPlaceHolder_lbl1GRB3").show();
                $("#BodyContentPlaceHolder_lbl2GRB3").text("years of age inclusive");
                $("#BodyContentPlaceHolder_lbl2GRB3").show();
            }
        });
        $("#BodyContentPlaceHolder_radio2GRA3").change(function () { localStorage.setItem("radio2GRA3", $("#BodyContentPlaceHolder_radio2GRA3 :checked").val()); });
        $("#BodyContentPlaceHolder_radio1GRB2 [value='" + localStorage.getItem("radio1GRB2") + "']").prop('checked', true);
        $("#BodyContentPlaceHolder_radio1GRB3 [value='" + localStorage.getItem("radio1GRB3") + "']").prop('checked', true);

        $("#BodyContentPlaceHolder_radio1GRB1").change(function () {
            localStorage.setItem("radio1GRB1", $("#BodyContentPlaceHolder_radio1GRB1 :checked").val());
            if ($("#BodyContentPlaceHolder_radio1GRB1 :checked").val() == "All") {
                $("#BodyContentPlaceHolder_FromAgeGRB1").hide();
                $("#BodyContentPlaceHolder_ToAgeGRB1").hide();
                $("#BodyContentPlaceHolder_lbl1GRB1").text("(All age groups)");
                $("#BodyContentPlaceHolder_lbl1GRB1").show();
                $("#BodyContentPlaceHolder_lbl2GRB1").text(" ");
                $("#BodyContentPlaceHolder_lbl2GRB1").hide();
            }
            if ($("#BodyContentPlaceHolder_radio1GRB1 :checked").val() == "Under") {
                $("#BodyContentPlaceHolder_FromAgeGRB1").hide();
                $("#BodyContentPlaceHolder_ToAgeGRB1").show();
                $("#BodyContentPlaceHolder_lbl1GRB1").text(" ");
                $("#BodyContentPlaceHolder_lbl1GRB1").hide();
                $("#BodyContentPlaceHolder_lbl2GRB1").text("years of age");
                $("#BodyContentPlaceHolder_lbl2GRB1").show();
            }
            if ($("#BodyContentPlaceHolder_radio1GRB1 :checked").val() == "Over") {
                $("#BodyContentPlaceHolder_FromAgeGRB1").show();
                $("#BodyContentPlaceHolder_ToAgeGRB1").hide();
                $("#BodyContentPlaceHolder_lbl1GRB1").text("years of age");
                $("#BodyContentPlaceHolder_lbl1GRB1").show();
                $("#BodyContentPlaceHolder_lbl2GRB1").text(" ");
                $("#BodyContentPlaceHolder_lbl2GRB1").hide();
            }
            if ($("#BodyContentPlaceHolder_radio1GRB1 :checked").val() == "Between") {
                $("#BodyContentPlaceHolder_FromAgeGRB1").show();
                $("#BodyContentPlaceHolder_ToAgeGRB1").show();
                $("#BodyContentPlaceHolder_lbl1GRB1").text("years and");
                $("#BodyContentPlaceHolder_lbl1GRB1").show();
                $("#BodyContentPlaceHolder_lbl2GRB1").text("years of age inclusive");
                $("#BodyContentPlaceHolder_lbl2GRB1").show();
            }
        });
        $("#BodyContentPlaceHolder_radio1GRB2").change(function () {
            localStorage.setItem("radio1GRB2", $("#BodyContentPlaceHolder_radio1GRB2 :checked").val());
            if ($("#BodyContentPlaceHolder_radio1GRB2 :checked").val() == "All") {
                $("#BodyContentPlaceHolder_FromAgeGRB2").hide();
                $("#BodyContentPlaceHolder_ToAgeGRB2").hide();
                $("#BodyContentPlaceHolder_lbl1GRB2").text("(All age groups)");
                $("#BodyContentPlaceHolder_lbl1GRB2").show();
                $("#BodyContentPlaceHolder_lbl2GRB2").text(" ");
                $("#BodyContentPlaceHolder_lbl2GRB2").hide();
            }
            if ($("#BodyContentPlaceHolder_radio1GRB2 :checked").val() == "Under") {
                $("#BodyContentPlaceHolder_FromAgeGRB2").hide();
                $("#BodyContentPlaceHolder_ToAgeGRB2").show();
                $("#BodyContentPlaceHolder_lbl1GRB2").text(" ");
                $("#BodyContentPlaceHolder_lbl1GRB2").hide();
                $("#BodyContentPlaceHolder_lbl2GRB2").text("years of age");
                $("#BodyContentPlaceHolder_lbl2GRB2").show();
            }
            if ($("#BodyContentPlaceHolder_radio1GRB2 :checked").val() == "Over") {
                $("#BodyContentPlaceHolder_FromAgeGRB2").show();
                $("#BodyContentPlaceHolder_ToAgeGRB2").hide();
                $("#BodyContentPlaceHolder_lbl1GRB2").text("years of age");
                $("#BodyContentPlaceHolder_lbl1GRB2").show();
                $("#BodyContentPlaceHolder_lbl2GRB2").text(" ");
                $("#BodyContentPlaceHolder_lbl2GRB2").hide();
            }
            if ($("#BodyContentPlaceHolder_radio1GRB2 :checked").val() == "Between") {
                $("#BodyContentPlaceHolder_FromAgeGRB2").show();
                $("#BodyContentPlaceHolder_ToAgeGRB2").show();
                $("#BodyContentPlaceHolder_lbl1GRB2").text("years and");
                $("#BodyContentPlaceHolder_lbl1GRB2").show();
                $("#BodyContentPlaceHolder_lbl2GRB2").text("years of age inclusive");
                $("#BodyContentPlaceHolder_lbl2GRB2").show();
            }
        });
        $("#BodyContentPlaceHolder_radio1GRB3").change(function () {
            localStorage.setItem("radio1GRB3", $("#BodyContentPlaceHolder_radio1GRB3 :checked").val());
            if ($("#BodyContentPlaceHolder_radio1GRB3 :checked").val() == "All") {
                $("#BodyContentPlaceHolder_FromAgeGRB3").hide();
                $("#BodyContentPlaceHolder_ToAgeGRB3").hide();
                $("#BodyContentPlaceHolder_lbl1GRB3").text("(All age groups)");
                $("#BodyContentPlaceHolder_lbl1GRB3").show();
                $("#BodyContentPlaceHolder_lbl2GRB3").text(" ");
                $("#BodyContentPlaceHolder_lbl2GRB3").hide();
            }
            if ($("#BodyContentPlaceHolder_radio1GRB3 :checked").val() == "Under") {
                $("#BodyContentPlaceHolder_FromAgeGRB3").hide();
                $("#BodyContentPlaceHolder_ToAgeGRB3").show();
                $("#BodyContentPlaceHolder_lbl1GRB3").text(" ");
                $("#BodyContentPlaceHolder_lbl1GRB3").hide();
                $("#BodyContentPlaceHolder_lbl2GRB3").text("years of age");
                $("#BodyContentPlaceHolder_lbl2GRB3").show();
            }
            if ($("#BodyContentPlaceHolder_radio1GRB3 :checked").val() == "Over") {
                $("#BodyContentPlaceHolder_FromAgeGRB3").show();
                $("#BodyContentPlaceHolder_ToAgeGRB3").hide();
                $("#BodyContentPlaceHolder_lbl1GRB3").text("years of age");
                $("#BodyContentPlaceHolder_lbl1GRB3").show();
                $("#BodyContentPlaceHolder_lbl2GRB3").text(" ");
                $("#BodyContentPlaceHolder_lbl2GRB3").hide();
            }
            if ($("#BodyContentPlaceHolder_radio1GRB3 :checked").val() == "Between") {
                $("#BodyContentPlaceHolder_FromAgeGRB3").show();
                $("#BodyContentPlaceHolder_ToAgeGRB3").show();
                $("#BodyContentPlaceHolder_lbl1GRB3").text("years and");
                $("#BodyContentPlaceHolder_lbl1GRB3").show();
                $("#BodyContentPlaceHolder_lbl2GRB3").text("years of age inclusive");
                $("#BodyContentPlaceHolder_lbl2GRB3").show();
            }
        });
        $("#BodyContentPlaceHolder_radio1GRB5").change(function () {
            localStorage.setItem("radio1GRB5", $("#BodyContentPlaceHolder_radio1GRB5 :checked").val());
            if ($("#BodyContentPlaceHolder_radio1GRB5 :checked").val() == "All") {
                $("#BodyContentPlaceHolder_FromAgeGRB5").hide();
                $("#BodyContentPlaceHolder_ToAgeGRB5").hide();
                $("#BodyContentPlaceHolder_lbl1GRB5").text("(All age groups)");
                $("#BodyContentPlaceHolder_lbl1GRB5").show();
                $("#BodyContentPlaceHolder_lbl2GRB5").text(" ");
                $("#BodyContentPlaceHolder_lbl2GRB5").hide();
            }
            if ($("#BodyContentPlaceHolder_radio1GRB5 :checked").val() == "Under") {
                $("#BodyContentPlaceHolder_FromAgeGRB5").hide();
                $("#BodyContentPlaceHolder_ToAgeGRB5").show();
                $("#BodyContentPlaceHolder_lbl1GRB5").text(" ");
                $("#BodyContentPlaceHolder_lbl1GRB5").hide();
                $("#BodyContentPlaceHolder_lbl2GRB5").text("years of age");
                $("#BodyContentPlaceHolder_lbl2GRB5").show();
            }
            if ($("#BodyContentPlaceHolder_radio1GRB5 :checked").val() == "Over") {
                $("#BodyContentPlaceHolder_FromAgeGRB5").show();
                $("#BodyContentPlaceHolder_ToAgeGRB5").hide();
                $("#BodyContentPlaceHolder_lbl1GRB5").text("years of age");
                $("#BodyContentPlaceHolder_lbl1GRB5").show();
                $("#BodyContentPlaceHolder_lbl2GRB5").text(" ");
                $("#BodyContentPlaceHolder_lbl2GRB5").hide();
            }
            if ($("#BodyContentPlaceHolder_radio1GRB5 :checked").val() == "Between") {
                $("#BodyContentPlaceHolder_FromAgeGRB5").show();
                $("#BodyContentPlaceHolder_ToAgeGRB5").show();
                $("#BodyContentPlaceHolder_lbl1GRB5").text("years and");
                $("#BodyContentPlaceHolder_lbl1GRB5").show();
                $("#BodyContentPlaceHolder_lbl2GRB5").text("years of age inclusive");
                $("#BodyContentPlaceHolder_lbl2GRB5").show();
            }
        });
        $("#BodyContentPlaceHolder_radio1GRC1").change(function () { localStorage.setItem("radio1GRC1", $("#BodyContentPlaceHolder_radio1GRC1 :checked").val()); });
        $("#BodyContentPlaceHolder_radio1GRC3").change(function () { localStorage.setItem("radio1GRC3", $("#BodyContentPlaceHolder_radio1GRC3 :checked").val()); });
        $("#BodyContentPlaceHolder_radio1GRC4").change(function () { localStorage.setItem("radio1GRC4", $("#BodyContentPlaceHolder_radio1GRC4 :checked").val()); });
        $("#BodyContentPlaceHolder_radio1GRC5").change(function () { localStorage.setItem("radio1GRC5", $("#BodyContentPlaceHolder_radio1GRC5 :checked").val()); });
        $("#BodyContentPlaceHolder_radio1GRC7").change(function () {
            localStorage.setItem("radio1GRC7", $("#BodyContentPlaceHolder_radio1GRC7 :checked").val());
            if ($("#BodyContentPlaceHolder_radio1GRC7 :checked").val() == "All") {
                $("#BodyContentPlaceHolder_FromAgeGRC7").hide();
                $("#BodyContentPlaceHolder_ToAgeGRC7").hide();
                $("#BodyContentPlaceHolder_lbl1GRC7").text("(All age groups)");
                $("#BodyContentPlaceHolder_lbl1GRC7").show();
                $("#BodyContentPlaceHolder_lbl2GRC7").text(" ");
                $("#BodyContentPlaceHolder_lbl2GRC7").hide();
            }
            if ($("#BodyContentPlaceHolder_radio1GRC7 :checked").val() == "Under") {
                $("#BodyContentPlaceHolder_FromAgeGRC7").hide();
                $("#BodyContentPlaceHolder_ToAgeGRC7").show();
                $("#BodyContentPlaceHolder_lbl1GRC7").text(" ");
                $("#BodyContentPlaceHolder_lbl1GRC7").hide();
                $("#BodyContentPlaceHolder_lbl2GRC7").text("years of age");
                $("#BodyContentPlaceHolder_lbl2GRC7").show();
            }
            if ($("#BodyContentPlaceHolder_radio1GRC7 :checked").val() == "Over") {
                $("#BodyContentPlaceHolder_FromAgeGRC7").show();
                $("#BodyContentPlaceHolder_ToAgeGRC7").hide();
                $("#BodyContentPlaceHolder_lbl1GRC7").text("years of age");
                $("#BodyContentPlaceHolder_lbl1GRC7").show();
                $("#BodyContentPlaceHolder_lbl2GRC7").text(" ");
                $("#BodyContentPlaceHolder_lbl2GRC7").hide();
            }
            if ($("#BodyContentPlaceHolder_radio1GRC7 :checked").val() == "Between") {
                $("#BodyContentPlaceHolder_FromAgeGRC7").show();
                $("#BodyContentPlaceHolder_ToAgeGRC7").show();
                $("#BodyContentPlaceHolder_lbl1GRC7").text("years and");
                $("#BodyContentPlaceHolder_lbl1GRC7").show();
                $("#BodyContentPlaceHolder_lbl2GRC7").text("years of age inclusive");
                $("#BodyContentPlaceHolder_lbl2GRC7").show();
            }
        });
        $("#BodyContentPlaceHolder_radio3GRC7").change(function () {
            localStorage.setItem("radio3GRC7", $("#BodyContentPlaceHolder_radio3GRC7 :checked").val());
            if ($("#BodyContentPlaceHolder_radio3GRC7 input:radio:checked").val() == "1") {
                $("#ctl00_BodyContentPlaceHolder_lbl3GRC7").text("Include blanks as Zeroes");
                $("#BodyContentPlaceHolder_cb3GRC7").show();
                $("#_rfdSkinnedBodyContentPlaceHolder_cb3GRC7").show();
            }
            if ($("#BodyContentPlaceHolder_radio3GRC7 input:radio:checked").val() == "2") {
                $("#ctl00_BodyContentPlaceHolder_lbl3GRC7").text("Include null doses in calculations");
                $("#BodyContentPlaceHolder_cb3GRC7").show();
                $("#_rfdSkinnedBodyContentPlaceHolder_cb3GRC7").show();
            }
            if ($("#BodyContentPlaceHolder_radio3GRC7 input:radio:checked").val() == "3") {
                $("#ctl00_BodyContentPlaceHolder_lbl3GRC7").text("");
                $("#_rfdSkinnedBodyContentPlaceHolder_cb3GRC7").hide();
                $("#BodyContentPlaceHolder_cb3GRC7").hide();
                $("#BodyContentPlaceHolder_cb3GRC7").val(false);
                $("#BodyContentPlaceHolder_cb3GRC7").prop("checked", false)
                localStorage.setItem("cb3GRC7", false);
            }

        });
        $("#BodyContentPlaceHolder_FromAgeGRA3").change(function () { localStorage.setItem("FromAgeGRA3", $("#BodyContentPlaceHolder_FromAgeGRA3").val()); });
        $("#BodyContentPlaceHolder_FromAgeGRB1").change(function () { localStorage.setItem("FromAgeGRB1", $("#BodyContentPlaceHolder_FromAgeGRB1").val()); });
        $("#BodyContentPlaceHolder_FromAgeGRB2").change(function () { localStorage.setItem("FromAgeGRB2", $("#BodyContentPlaceHolder_FromAgeGRB2").val()); });
        $("#BodyContentPlaceHolder_FromAgeGRB3").change(function () { localStorage.setItem("FromAgeGRB3", $("#BodyContentPlaceHolder_FromAgeGRB3").val()); });
        $("#BodyContentPlaceHolder_FromAgeGRB5").change(function () { localStorage.setItem("FromAgeGRB5", $("#BodyContentPlaceHolder_FromAgeGRB5").val()); });
        $("#BodyContentPlaceHolder_FromAgeGRC7").change(function () { localStorage.setItem("FromAgeGRC7", $("#BodyContentPlaceHolder_FromAgeGRC7").val()); });

        $("#BodyContentPlaceHolder_radio2GRC7").change(function () { localStorage.setItem("radio2GRC7", $("#BodyContentPlaceHolder_radio2GRC7 :checked").val()); });

        $("#BodyContentPlaceHolder_ToAgeGRA3").change(function () { localStorage.setItem("ToAgeGRA3", $("#BodyContentPlaceHolder_ToAgeGRA3").val()); });
        $("#BodyContentPlaceHolder_ToAgeGRB1").change(function () { localStorage.setItem("ToAgeGRB1", $("#BodyContentPlaceHolder_ToAgeGRB1").val()); });
        $("#BodyContentPlaceHolder_ToAgeGRB2").change(function () { localStorage.setItem("ToAgeGRB2", $("#BodyContentPlaceHolder_ToAgeGRB2").val()); });
        $("#BodyContentPlaceHolder_ToAgeGRB3").change(function () { localStorage.setItem("ToAgeGRB3", $("#BodyContentPlaceHolder_ToAgeGRB3").val()); });
        $("#BodyContentPlaceHolder_ToAgeGRB5").change(function () { localStorage.setItem("ToAgeGRB5", $("#BodyContentPlaceHolder_ToAgeGRB5").val()); });
        $("#BodyContentPlaceHolder_ToAgeGRC7").change(function () { localStorage.setItem("ToAgeGRC7", $("#BodyContentPlaceHolder_ToAgeGRC7").val()); });
        loadDefaultsReports();
        $("#BodyContentPlaceHolder_cb1GRA2").change(function () { localStorage.setItem("cb1GRA2", $("#BodyContentPlaceHolder_cb1GRA2").is(":checked")); });
        $("#BodyContentPlaceHolder_cb2GRA2").change(function () { localStorage.setItem("cb2GRA2", $("#BodyContentPlaceHolder_cb2GRA2").is(":checked")); });
        $("#BodyContentPlaceHolder_cb3GRA2").change(function () { localStorage.setItem("cb3GRA2", $("#BodyContentPlaceHolder_cb3GRA2").is(":checked")); });
        $("#BodyContentPlaceHolder_cb4GRA2").change(function () { localStorage.setItem("cb4GRA2", $("#BodyContentPlaceHolder_cb4GRA2").is(":checked")); });
        $("#BodyContentPlaceHolder_cb1GRA3").change(function () { localStorage.setItem("cb1GRA3", $("#BodyContentPlaceHolder_cb1GRA3").is(":checked")); });
        $("#BodyContentPlaceHolder_cb2GRA3").change(function () { localStorage.setItem("cb2GRA3", $("#BodyContentPlaceHolder_cb2GRA3").is(":checked")); });
        $("#BodyContentPlaceHolder_cb3GRA3").change(function () { localStorage.setItem("cb3GRA3", $("#BodyContentPlaceHolder_cb3GRA3").is(":checked")); });
        $("#BodyContentPlaceHolder_cb4GRA3").change(function () { localStorage.setItem("cb4GRA3", $("#BodyContentPlaceHolder_cb4GRA3").is(":checked")); });
        $("#BodyContentPlaceHolder_cb5GRA3").change(function () { localStorage.setItem("cb5GRA3", $("#BodyContentPlaceHolder_cb5GRA3").is(":checked")); });
        $("#BodyContentPlaceHolder_cb6GRA3").change(function () { localStorage.setItem("cb6GRA3", $("#BodyContentPlaceHolder_cb6GRA3").is(":checked")); });
        $("#BodyContentPlaceHolder_cb1GRA4").change(function () { localStorage.setItem("cb1GRA4", $("#BodyContentPlaceHolder_cb1GRA4").is(":checked")); });
        $("#BodyContentPlaceHolder_cb2GRA4").change(function () { localStorage.setItem("cb2GRA4", $("#BodyContentPlaceHolder_cb2GRA4").is(":checked")); });
        $("#BodyContentPlaceHolder_cb1GRA5").change(function () { localStorage.setItem("cb1GRA5", $("#BodyContentPlaceHolder_cb1GRA5").is(":checked")); });
        $("#BodyContentPlaceHolder_cb2GRA5").change(function () { localStorage.setItem("cb2GRA5", $("#BodyContentPlaceHolder_cb2GRA5").is(":checked")); });
        $("#BodyContentPlaceHolder_cb1GRB1").change(function () { localStorage.setItem("cb1GRB1", $("#BodyContentPlaceHolder_cb1GRB1").is(":checked")); });
        $("#BodyContentPlaceHolder_cb2GRB1").change(function () { localStorage.setItem("cb2GRB1", $("#BodyContentPlaceHolder_cb2GRB1").is(":checked")); });
        $("#BodyContentPlaceHolder_cb3GRB1").change(function () { localStorage.setItem("cb3GRB1", $("#BodyContentPlaceHolder_cb3GRB1").is(":checked")); });
        $("#BodyContentPlaceHolder_cb1GRB2").change(function () { localStorage.setItem("cb1GRB2", $("#BodyContentPlaceHolder_cb1GRB2").is(":checked")); });
        $("#BodyContentPlaceHolder_cb2GRB2").change(function () { localStorage.setItem("cb2GRB2", $("#BodyContentPlaceHolder_cb2GRB2").is(":checked")); });
        $("#BodyContentPlaceHolder_cb1GRB3").change(function () { localStorage.setItem("cb1GRB3", $("#BodyContentPlaceHolder_cb1GRB3").is(":checked")); });
        $("#BodyContentPlaceHolder_cb2GRB3").change(function () { localStorage.setItem("cb2GRB3", $("#BodyContentPlaceHolder_cb2GRB3").is(":checked")); });
        $("#BodyContentPlaceHolder_cb3GRB3").change(function () { localStorage.setItem("cb3GRB3", $("#BodyContentPlaceHolder_cb3GRB3").is(":checked")); });
        $("#BodyContentPlaceHolder_cb1Tumour").change(function () { localStorage.setItem("cb1Tumour", $("#BodyContentPlaceHolder_cb1Tumour").is(":checked")); });
        $("#BodyContentPlaceHolder_cb2Tumour").change(function () { localStorage.setItem("cb2Tumour", $("#BodyContentPlaceHolder_cb2Tumour").is(":checked")); });
        $("#BodyContentPlaceHolder_cb3Tumour").change(function () { localStorage.setItem("cb3Tumour", $("#BodyContentPlaceHolder_cb3Tumour").is(":checked")); });
        $("#BodyContentPlaceHolder_cb4Tumour").change(function () { localStorage.setItem("cb4Tumour", $("#BodyContentPlaceHolder_cb4Tumour").is(":checked")); });
        $("#BodyContentPlaceHolder_cb5Tumour").change(function () { localStorage.setItem("cb5Tumour", $("#BodyContentPlaceHolder_cb5Tumour").is(":checked")); });
        $("#BodyContentPlaceHolder_cb6Tumour").change(function () { localStorage.setItem("cb6Tumour", $("#BodyContentPlaceHolder_cb6Tumour").is(":checked")); });
        $("#BodyContentPlaceHolder_cb7Tumour").change(function () { localStorage.setItem("cb7Tumour", $("#BodyContentPlaceHolder_cb7Tumour").is(":checked")); });
        $("#BodyContentPlaceHolder_cb1GRB5").change(function () { localStorage.setItem("cb1GRB5", $("#BodyContentPlaceHolder_cb1GRB5").is(":checked")); });
        $("#BodyContentPlaceHolder_cb2GRB5").change(function () { localStorage.setItem("cb2GRB5", $("#BodyContentPlaceHolder_cb2GRB5").is(":checked")); });
        $("#BodyContentPlaceHolder_cb1GRC1").change(function () { localStorage.setItem("cb1GRC1", $("#BodyContentPlaceHolder_cb1GRC1").is(":checked")); });
        $("#BodyContentPlaceHolder_cb2GRC1").change(function () { localStorage.setItem("cb2GRC1", $("#BodyContentPlaceHolder_cb2GRC1").is(":checked")); });
        $("#BodyContentPlaceHolder_cb1GRC2").change(function () { localStorage.setItem("cb1GRC2", $("#BodyContentPlaceHolder_cb1GRC2").is(":checked")); });
        $("#BodyContentPlaceHolder_cb2GRC2").change(function () { localStorage.setItem("cb2GRC2", $("#BodyContentPlaceHolder_cb2GRC2").is(":checked")); });
        $("#BodyContentPlaceHolder_cb3GRC2").change(function () { localStorage.setItem("cb3GRC2", $("#BodyContentPlaceHolder_cb3GRC2").is(":checked")); });
        $("#BodyContentPlaceHolder_cb1GRC3").change(function () { localStorage.setItem("cb1GRC3", $("#BodyContentPlaceHolder_cb1GRC3").is(":checked")); });
        $("#BodyContentPlaceHolder_cb2GRC3").change(function () { localStorage.setItem("cb2GRC3", $("#BodyContentPlaceHolder_cb2GRC3").is(":checked")); });
        $("#BodyContentPlaceHolder_cb3GRC3").change(function () { localStorage.setItem("cb3GRC3", $("#BodyContentPlaceHolder_cb3GRC3").is(":checked")); });
        $("#BodyContentPlaceHolder_cb4GRC3").change(function () { localStorage.setItem("cb4GRC3", $("#BodyContentPlaceHolder_cb4GRC3").is(":checked")); });
        $("#BodyContentPlaceHolder_cb6GRC3").change(function () { localStorage.setItem("cb6GRC3", $("#BodyContentPlaceHolder_cb6GRC3").is(":checked")); });
        $("#BodyContentPlaceHolder_cb3GRC7").change(function () { localStorage.setItem("cb3GRC7", $("#BodyContentPlaceHolder_cb3GRC7").is(":checked")); });
        $("#BodyContentPlaceHolder_cb1GRC8").change(function () { localStorage.setItem("cb1GRC8", $("#BodyContentPlaceHolder_cb1GRC8").is(":checked")); });
        $("#BodyContentPlaceHolder_cb2GRC8").change(function () { localStorage.setItem("cb2GRC8", $("#BodyContentPlaceHolder_cb2GRC8").is(":checked")); });
        InitTabs();
        $("#BodyContentPlaceHolder_RadTabStrip1").show();
        $("#RTSP").show();
        $("#BodyContentPlaceHolder_cbHideSuppressed").change(function () {
            formChange();
        });
        $("#ctl00_BodyContentPlaceHolder_ComboConsultants_Input").change(function () {
            formChange();
        });
    });
    function formChange() {
        $("#ISMFilter").val("");
        ct = $("#ctl00_BodyContentPlaceHolder_ComboConsultants_Input").val();
        var cb = document.getElementById("<%=cbHideSuppressed.ClientID%>").checked;
        var hs = "";
        if (cb === true) {
            hs = "1";
        } else {
            hs = "0";
        }
        var listbox1 = $find("<%=RadListBox1.ClientID%>");
        var item1 = new Telerik.Web.UI.RadListBoxItem();
        var ItemsNo1 = listbox1.get_items().get_count();
        var usr = document.getElementById("<%=SUID.ClientID%>").getAttribute("value");
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
        var listbox2 = $find("<%=RadListBox2.ClientID%>");
        var item2 = new Telerik.Web.UI.RadListBoxItem();
        var ItemsNo2 = listbox2.get_items().get_count();
        listbox2.get_items().clear();
    }
    var FirstTime = true;
    function SetFirstTab() {
        var tabStrip = $find("<%=RadTabStripParameters.ClientID%>");
            var tabs = tabStrip.get_tabs();
            var tab = tabStrip.findTabByText(tabs.getTab(0).get_text());
            if (FirstTime == true) {
                FirstTime = false;
                tab.select();
            }
        }
        function InitTabs() {
            for (var i = 0; i < GRSArray.length; i++) {
                changeTabStatus(i);
            }
            document.getElementById("RTSP").setAttribute("class", "tabsContainer");
            $("#BodyContentPlaceHolder_RadTabStrip1").show();
            SetFirstTab();
        }
        function loadDefaultsReports() {
            var i = 0
            for (i = 0; i < checkArray.length; i++) {
                $("#BodyContentPlaceHolder_" + checkArray[i]).prop("checked", localStorage.getItem(checkArray[i]));
            }

            $("#BodyContentPlaceHolder_FromAgeGRA3").val(localStorage.getItem("FromAgeGRA3"));
            if ($("#BodyContentPlaceHolder_FromAgeGRA3").val() == "") { $("#BodyContentPlaceHolder_FromAgeGRA3").val(0); }
            $("#BodyContentPlaceHolder_FromAgeGRB1").val(localStorage.getItem("FromAgeGRB1"));
            if ($("#BodyContentPlaceHolder_FromAgeGRB1").val() == "") { $("#BodyContentPlaceHolder_FromAgeGRB1").val(0); }
            $("#BodyContentPlaceHolder_FromAgeGRB2").val(localStorage.getItem("FromAgeGRB2"));
            if ($("#BodyContentPlaceHolder_FromAgeGRB2").val() == "") { $("#BodyContentPlaceHolder_FromAgeGRB2").val(0); }
            $("#BodyContentPlaceHolder_FromAgeGRB3").val(localStorage.getItem("FromAgeGRB3"));
            if ($("#BodyContentPlaceHolder_FromAgeGRB3").val() == "") { $("#BodyContentPlaceHolder_FromAgeGRB3").val(0); }
            $("#BodyContentPlaceHolder_FromAgeGRB5").val(localStorage.getItem("FromAgeGRB5"));
            if ($("#BodyContentPlaceHolder_FromAgeGRB5").val() == "") { $("#BodyContentPlaceHolder_FromAgeGRB5").val(0); }
            $("#BodyContentPlaceHolder_FromAgeGRC7").val(localStorage.getItem("FromAgeGRC7"));
            if ($("#BodyContentPlaceHolder_FromAgeGRC7").val() == "") { $("#BodyContentPlaceHolder_FromAgeGRC7").val(0); }
            $("#BodyContentPlaceHolder_ToAgeGRA3").val(localStorage.getItem("ToAgeGRA3"));
            if ($("#BodyContentPlaceHolder_ToAgeGRA3").val() == "") { $("#BodyContentPlaceHolder_ToAgeGRA3").val(200); }
            $("#BodyContentPlaceHolder_ToAgeGRB1").val(localStorage.getItem("ToAgeGRB1"));
            if ($("#BodyContentPlaceHolder_ToAgeGRB1").val() == "") { $("#BodyContentPlaceHolder_ToAgeGRB1").val(200); }
            $("#BodyContentPlaceHolder_ToAgeGRB2").val(localStorage.getItem("ToAgeGRB2"));
            if ($("#BodyContentPlaceHolder_ToAgeGRB2").val() == "") { $("#BodyContentPlaceHolder_ToAgeGRB2").val(200); }
            $("#BodyContentPlaceHolder_ToAgeGRB3").val(localStorage.getItem("ToAgeGRB3"));
            if ($("#BodyContentPlaceHolder_ToAgeGRB3").val() == "") { $("#BodyContentPlaceHolder_ToAgeGRB3").val(200); }
            $("#BodyContentPlaceHolder_ToAgeGRB5").val(localStorage.getItem("ToAgeGRB5"));
            if ($("#BodyContentPlaceHolder_ToAgeGRB5").val() == "") { $("#BodyContentPlaceHolder_ToAgeGRB5").val(200); }
            $("#BodyContentPlaceHolder_ToAgeGRC7").val(localStorage.getItem("ToAgeGRC7"));
            if ($("#BodyContentPlaceHolder_ToAgeGRC7").val() == "") { $("#BodyContentPlaceHolder_ToAgeGRC7").val(200); }
            $("#BodyContentPlaceHolder_in1GRB1").val(localStorage.getItem("in1GRB1"));
            $("#BodyContentPlaceHolder_in2GRB1").val(localStorage.getItem("in2GRB1"));
            $("#BodyContentPlaceHolder_in3GRB1").val(localStorage.getItem("in3GRB1"));

            $("#BodyContentPlaceHolder_in1GB5").val(localStorage.getItem("in1GB5"));
            $("#BodyContentPlaceHolder_in2GB5").val(localStorage.getItem("in2GB5"));
            $("#BodyContentPlaceHolder_in3GB5").val(localStorage.getItem("in3GB5"));
            $("#BodyContentPlaceHolder_in4GB5").val(localStorage.getItem("in4GB5"));
            $("#BodyContentPlaceHolder_in5GB5").val(localStorage.getItem("in5GB5"));
            $("#BodyContentPlaceHolder_in6GB5").val(localStorage.getItem("in6GB5"));
            $("#BodyContentPlaceHolder_in7GB5").val(localStorage.getItem("in7GB5"));

            $("#BodyContentPlaceHolder_radio1GRA3 [value='" + localStorage.getItem("radio1GRA3") + "']").prop('checked', true);
            $("#BodyContentPlaceHolder_radio2GRA3 [value='" + localStorage.getItem("radio2GRA3") + "']").prop('checked', true);
            if ($("#BodyContentPlaceHolder_radio1GRA3 :checked").val() == "All") {
                $("#BodyContentPlaceHolder_FromAgeGRA3").hide();
                $("#BodyContentPlaceHolder_ToAgeGRA3").hide();
                $("#BodyContentPlaceHolder_lbl1GRA3").text("(All age groups)");
                $("#BodyContentPlaceHolder_lbl1GRA3").show();
                $("#BodyContentPlaceHolder_lbl2GRA3").text(" ");
                $("#BodyContentPlaceHolder_lbl2GRA3").hide();
            }
            if ($("#BodyContentPlaceHolder_radio1GRA3 :checked").val() == "Under") {
                $("#BodyContentPlaceHolder_FromAgeGRA3").hide();
                $("#BodyContentPlaceHolder_ToAgeGRA3").show();
                $("#BodyContentPlaceHolder_lbl1GRA3").text(" ");
                $("#BodyContentPlaceHolder_lbl1GRA3").hide();
                $("#BodyContentPlaceHolder_lbl2GRA3").text("years of age");
                $("#BodyContentPlaceHolder_lbl2GRA3").show();
            }
            if ($("#BodyContentPlaceHolder_radio1GRA3 :checked").val() == "Over") {
                $("#BodyContentPlaceHolder_FromAgeGRA3").show();
                $("#BodyContentPlaceHolder_ToAgeGRA3").hide();
                $("#BodyContentPlaceHolder_lbl1GRA3").text("years of age");
                $("#BodyContentPlaceHolder_lbl1GRA3").show();
                $("#BodyContentPlaceHolder_lbl2GRA3").text(" ");
                $("#BodyContentPlaceHolder_lbl2GRA3").hide();
            }
            if ($("#BodyContentPlaceHolder_radio1GRA3 :checked").val() == "Between") {
                $("#BodyContentPlaceHolder_FromAgeGRA3").show();
                $("#BodyContentPlaceHolder_ToAgeGRA3").show();
                $("#BodyContentPlaceHolder_lbl1GRA3").text("years and");
                $("#BodyContentPlaceHolder_lbl1GRA3").show();
                $("#BodyContentPlaceHolder_lbl2GRA3").text("years of age inclusive");
                $("#BodyContentPlaceHolder_lbl2GRA3").show();
            }
            $("#BodyContentPlaceHolder_radio1GRB1 [value='" + localStorage.getItem("radio1GRB1") + "']").prop('checked', true);
            if ($("#BodyContentPlaceHolder_radio1GRB1 :checked").val() == "All") {
                $("#BodyContentPlaceHolder_FromAgeGRB1").hide();
                $("#BodyContentPlaceHolder_ToAgeGRB1").hide();
                $("#BodyContentPlaceHolder_lbl1GRB1").text("(All age groups)");
                $("#BodyContentPlaceHolder_lbl1GRB1").show();
                $("#BodyContentPlaceHolder_lbl2GRB1").text(" ");
                $("#BodyContentPlaceHolder_lbl2GRB1").hide();
            }
            if ($("#BodyContentPlaceHolder_radio1GRB1 :checked").val() == "Under") {
                $("#BodyContentPlaceHolder_FromAgeGRB1").hide();
                $("#BodyContentPlaceHolder_ToAgeGRB1").show();
                $("#BodyContentPlaceHolder_lbl1GRB1").text(" ");
                $("#BodyContentPlaceHolder_lbl1GRB1").hide();
                $("#BodyContentPlaceHolder_lbl2GRB1").text("years of age");
                $("#BodyContentPlaceHolder_lbl2GRB1").show();
            }
            if ($("#BodyContentPlaceHolder_radio1GRB1 :checked").val() == "Over") {
                $("#BodyContentPlaceHolder_FromAgeGRB1").show();
                $("#BodyContentPlaceHolder_ToAgeGRB1").hide();
                $("#BodyContentPlaceHolder_lbl1GRB1").text("years of age");
                $("#BodyContentPlaceHolder_lbl1GRB1").show();
                $("#BodyContentPlaceHolder_lbl2GRB1").text(" ");
                $("#BodyContentPlaceHolder_lbl2GRB1").hide();
            }
            if ($("#BodyContentPlaceHolder_radio1GRB1 :checked").val() == "Between") {
                $("#BodyContentPlaceHolder_FromAgeGRB1").show();
                $("#BodyContentPlaceHolder_ToAgeGRB1").show();
                $("#BodyContentPlaceHolder_lbl1GRB1").text("years and");
                $("#BodyContentPlaceHolder_lbl1GRB1").show();
                $("#BodyContentPlaceHolder_lbl2GRB1").text("years of age inclusive");
                $("#BodyContentPlaceHolder_lbl2GRB1").show();
            }
            $("#BodyContentPlaceHolder_radio1GRB2 input[value=" + localStorage.getItem("radio1GRB2") + "]").attr("checked", "checked");
            if ($("#BodyContentPlaceHolder_radio1GRB2 :checked").val() == "All") {
                $("#BodyContentPlaceHolder_FromAgeGRB2").hide();
                $("#BodyContentPlaceHolder_ToAgeGRB2").hide();
                $("#BodyContentPlaceHolder_lbl1GRB2").text("(All age groups)");
                $("#BodyContentPlaceHolder_lbl1GRB2").show();
                $("#BodyContentPlaceHolder_lbl2GRB2").text(" ");
                $("#BodyContentPlaceHolder_lbl2GRB2").hide();
            }
            if ($("#BodyContentPlaceHolder_radio1GRB2 :checked").val() == "Under") {
                $("#BodyContentPlaceHolder_FromAgeGRB2").hide();
                $("#BodyContentPlaceHolder_ToAgeGRB2").show();
                $("#BodyContentPlaceHolder_lbl1GRB2").text(" ");
                $("#BodyContentPlaceHolder_lbl1GRB2").hide();
                $("#BodyContentPlaceHolder_lbl2GRB2").text("years of age");
                $("#BodyContentPlaceHolder_lbl2GRB2").show();
            }
            if ($("#BodyContentPlaceHolder_radio1GRB2 :checked").val() == "Over") {
                $("#BodyContentPlaceHolder_FromAgeGRB2").show();
                $("#BodyContentPlaceHolder_ToAgeGRB2").hide();
                $("#BodyContentPlaceHolder_lbl1GRB2").text("years of age");
                $("#BodyContentPlaceHolder_lbl1GRB2").show();
                $("#BodyContentPlaceHolder_lbl2GRB2").text(" ");
                $("#BodyContentPlaceHolder_lbl2GRB2").hide();
            }
            if ($("#BodyContentPlaceHolder_radio1GRB2 :checked").val() == "Between") {
                $("#BodyContentPlaceHolder_FromAgeGRB2").show();
                $("#BodyContentPlaceHolder_ToAgeGRB2").show();
                $("#BodyContentPlaceHolder_lbl1GRB2").text("years and");
                $("#BodyContentPlaceHolder_lbl1GRB2").show();
                $("#BodyContentPlaceHolder_lbl2GRB2").text("years of age inclusive");
                $("#BodyContentPlaceHolder_lbl2GRB2").show();
            }
            $("#BodyContentPlaceHolder_radio1GRB3 [value='" + localStorage.getItem("radio1GRB3") + "']").prop('checked', true);
            if ($("#BodyContentPlaceHolder_radio1GRB3 :checked").val() == "All") {
                $("#BodyContentPlaceHolder_FromAgeGRB3").hide();
                $("#BodyContentPlaceHolder_ToAgeGRB3").hide();
                $("#BodyContentPlaceHolder_lbl1GRB3").text("(All age groups)");
                $("#BodyContentPlaceHolder_lbl1GRB3").show();
                $("#BodyContentPlaceHolder_lbl2GRB3").text(" ");
                $("#BodyContentPlaceHolder_lbl2GRB3").hide();
            }
            if ($("#BodyContentPlaceHolder_radio1GRB3 :checked").val() == "Under") {
                $("#BodyContentPlaceHolder_FromAgeGRB3").hide();
                $("#BodyContentPlaceHolder_ToAgeGRB3").show();
                $("#BodyContentPlaceHolder_lbl1GRB3").text(" ");
                $("#BodyContentPlaceHolder_lbl1GRB3").hide();
                $("#BodyContentPlaceHolder_lbl2GRB3").text("years of age");
                $("#BodyContentPlaceHolder_lbl2GRB3").show();
            }
            if ($("#BodyContentPlaceHolder_radio1GRB3 :checked").val() == "Over") {
                $("#BodyContentPlaceHolder_FromAgeGRB3").show();
                $("#BodyContentPlaceHolder_ToAgeGRB3").hide();
                $("#BodyContentPlaceHolder_lbl1GRB3").text("years of age");
                $("#BodyContentPlaceHolder_lbl1GRB3").show();
                $("#BodyContentPlaceHolder_lbl2GRB3").text(" ");
                $("#BodyContentPlaceHolder_lbl2GRB3").hide();
            }
            if ($("#BodyContentPlaceHolder_radio1GRB3 :checked").val() == "Between") {
                $("#BodyContentPlaceHolder_FromAgeGRB3").show();
                $("#BodyContentPlaceHolder_ToAgeGRB3").show();
                $("#BodyContentPlaceHolder_lbl1GRB3").text("years and");
                $("#BodyContentPlaceHolder_lbl1GRB3").show();
                $("#BodyContentPlaceHolder_lbl2GRB3").text("years of age inclusive");
                $("#BodyContentPlaceHolder_lbl2GRB3").show();
            }
            $("#BodyContentPlaceHolder_radio1GRB5 input[value=" + localStorage.getItem("radio1GRB5") + "]").attr("checked", "checked");
            if ($("#BodyContentPlaceHolder_radio1GRB5 :checked").val() == "All") {
                $("#BodyContentPlaceHolder_FromAgeGRB5").hide();
                $("#BodyContentPlaceHolder_ToAgeGRB5").hide();
                $("#BodyContentPlaceHolder_lbl1GRB5").text("(All age groups)");
                $("#BodyContentPlaceHolder_lbl1GRB5").show();
                $("#BodyContentPlaceHolder_lbl2GRB5").text(" ");
                $("#BodyContentPlaceHolder_lbl2GRB5").hide();
            }
            if ($("#BodyContentPlaceHolder_radio1GRB5 :checked").val() == "Under") {
                $("#BodyContentPlaceHolder_FromAgeGRB5").hide();
                $("#BodyContentPlaceHolder_ToAgeGRB5").show();
                $("#BodyContentPlaceHolder_lbl1GRB5").text(" ");
                $("#BodyContentPlaceHolder_lbl1GRB5").hide();
                $("#BodyContentPlaceHolder_lbl2GRB5").text("years of age");
                $("#BodyContentPlaceHolder_lbl2GRB5").show();
            }
            if ($("#BodyContentPlaceHolder_radio1GRB5 :checked").val() == "Over") {
                $("#BodyContentPlaceHolder_FromAgeGRB5").show();
                $("#BodyContentPlaceHolder_ToAgeGRB5").hide();
                $("#BodyContentPlaceHolder_lbl1GRB5").text("years of age");
                $("#BodyContentPlaceHolder_lbl1GRB5").show();
                $("#BodyContentPlaceHolder_lbl2GRB5").text(" ");
                $("#BodyContentPlaceHolder_lbl2GRB5").hide();
            }
            if ($("#BodyContentPlaceHolder_radio1GRB5 :checked").val() == "Between") {
                $("#BodyContentPlaceHolder_FromAgeGRB5").show();
                $("#BodyContentPlaceHolder_ToAgeGRB5").show();
                $("#BodyContentPlaceHolder_lbl1GRB5").text("years and");
                $("#BodyContentPlaceHolder_lbl1GRB5").show();
                $("#BodyContentPlaceHolder_lbl2GRB5").text("years of age inclusive");
                $("#BodyContentPlaceHolder_lbl2GRB5").show();
            }
            $("#BodyContentPlaceHolder_radio1GRC1 [value='" + localStorage.getItem("radio1GRC1") + "']").prop('checked', true);
            $("#BodyContentPlaceHolder_radio1GRC3 [value='" + localStorage.getItem("radio1GRC3") + "']").prop('checked', true);
            $("#BodyContentPlaceHolder_radio1GRC4 [value='" + localStorage.getItem("radio1GRC4") + "']").prop('checked', true);
            $("#BodyContentPlaceHolder_radio1GRC5 [value='" + localStorage.getItem("radio1GRC5") + "']").prop('checked', true);
            $("#BodyContentPlaceHolder_radio1GRC6 [value='" + localStorage.getItem("radio1GRC6") + "']").prop('checked', true);

            $("#BodyContentPlaceHolder_radio1GRC7 [value='" + localStorage.getItem("radio1GRC7") + "']").prop('checked', true);
            if ($("#BodyContentPlaceHolder_radio1GRC7 :checked").val() == "All") {
                $("#BodyContentPlaceHolder_FromAgeGRC7").hide();
                $("#BodyContentPlaceHolder_ToAgeGRC7").hide();
                $("#BodyContentPlaceHolder_lbl1GRC7").text("(All age groups)");
                $("#BodyContentPlaceHolder_lbl1GRC7").show();
                $("#BodyContentPlaceHolder_lbl2GRC7").text(" ");
                $("#BodyContentPlaceHolder_lbl2GRC7").hide();
            }
            if ($("#BodyContentPlaceHolder_radio1GRC7 :checked").val() == "Under") {
                $("#BodyContentPlaceHolder_FromAgeGRC7").hide();
                $("#BodyContentPlaceHolder_ToAgeGRC7").show();
                $("#BodyContentPlaceHolder_lbl1GRC7").text(" ");
                $("#BodyContentPlaceHolder_lbl1GRC7").hide();
                $("#BodyContentPlaceHolder_lbl2GRC7").text("years of age");
                $("#BodyContentPlaceHolder_lbl2GRC7").show();
            }
            if ($("#BodyContentPlaceHolder_radio1GRC7 :checked").val() == "Over") {
                $("#BodyContentPlaceHolder_FromAgeGRC7").show();
                $("#BodyContentPlaceHolder_ToAgeGRC7").hide();
                $("#BodyContentPlaceHolder_lbl1GRC7").text("years of age");
                $("#BodyContentPlaceHolder_lbl1GRC7").show();
                $("#BodyContentPlaceHolder_lbl2GRC7").text(" ");
                $("#BodyContentPlaceHolder_lbl2GRC7").hide();
            }
            if ($("#BodyContentPlaceHolder_radio1GRC7 :checked").val() == "Between") {
                $("#BodyContentPlaceHolder_FromAgeGRC7").show();
                $("#BodyContentPlaceHolder_ToAgeGRC7").show();
                $("#BodyContentPlaceHolder_lbl1GRC7").text("years and");
                $("#BodyContentPlaceHolder_lbl1GRC7").show();
                $("#BodyContentPlaceHolder_lbl2GRC7").text("years of age inclusive");
                $("#BodyContentPlaceHolder_lbl2GRC7").show();
            }
            $("#BodyContentPlaceHolder_radio2GRC7 [value='" + localStorage.getItem("radio2GRC7") + "']").prop('checked', true);
            $("#BodyContentPlaceHolder_radio3GRC7 [value='" + localStorage.getItem("radio3GRC7") + "']").prop('checked', true);
            return false;
        }
        function changeTabStatus(k) {
            var j = 0;
            var tabStripText = GRSTabsLabels[k];
            var pv = PVArray[k];
            var tabStrip = $find("<%=RadTabStripParameters.ClientID%>");
        var tab = tabStrip.findTabByText(tabStripText);
        var i = 0;
        if (GRSArray[k] === true) {
            tab.set_visible(true);
            tab.select();
            $("#" + pv).show();
        } else {
            tab.set_visible(false);
            var tabStrip = $find("<%=RadTabStripParameters.ClientID%>");
                var tabs = tabStrip.get_tabs();
                for (i = 0; i < tabs.get_count() ; i++) {
                    var tab = tabStrip.findTabByText(tabs.getTab(i).get_text());
                    if (tab.get_visible()) {
                        tab.select();
                    }
                }
            }
            return false;
        }
        function ResponseEnd() {
            InitTabs();
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
                    res = msg.d;
                },
                error: function (request, status, error) {
                    console.log(request.responseText);
                }
            });
            return res;
        }
</script>
</asp:Content>--%>
