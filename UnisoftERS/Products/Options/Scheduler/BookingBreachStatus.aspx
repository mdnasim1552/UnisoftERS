<%@ Page Language="vb" MasterPageFile="~/Templates/Scheduler.master" AutoEventWireup="false" Inherits="UnisoftERS.products_options_scheduler_BookingBreachStatus" CodeBehind="BookingBreachStatus.aspx.vb" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContentPlaceHolder" runat="Server">
    <title>Booking/Breach Status</title>
    <script type="text/javascript" src="../../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
    </style>

    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            $(window).on('load', function () {
            });
            $(document).ready(function () {
            });

            function openAddItemWindow(itemId, LabelName, LabelID, GI, nonGI, BreachDays, TextColour, HL7Code) {
                var oWnd = $find("<%= AddNewItemRadWindow.ClientID%>");
                if (itemId > 0) {
                    $find('<% =AddNewItemSaveRadButton.ClientID%>').set_text("Update");
                    oWnd.set_title('Edit Label');
                    $find("<%= DescriptionRadTextBox.ClientID%>").set_value(LabelName);
                    $find("<%= txtHL7Code.ClientID%>").set_value(HL7Code);
                   <%-- if (LabelName == "In Patient" || LabelName == "Routine") {
                        $find("<%= DescriptionRadTextBox.ClientID%>").disable();
                    }
                    else {
                        $find("<%= DescriptionRadTextBox.ClientID%>").enable();
                    }--%>
                   
                   
                    $find('<%= BreachDaysRadNumericTextBox.ClientID%>').set_value(BreachDays);
                    if (TextColour == "") {
                        $find("<%= BreachRadColourPicker.ClientID%>").set_selectedColor("#ffffff");
                    }
                    else {
                        $find("<%= BreachRadColourPicker.ClientID%>").set_selectedColor(TextColour);
                    }
                    $("#<%=hiddenItemId.ClientID%>").val(itemId);
                } else {
                    document.getElementById("tdItemTitle").innerHTML = '<b>Add new item</b>';
                    $find('<% =AddNewItemSaveRadButton.ClientID%>').set_text("Save");
                    oWnd.set_title('New Item');
                    $find("<%= DescriptionRadTextBox.ClientID%>").set_value("");
                    $find('<%= BreachDaysRadNumericTextBox.ClientID%>').set_value("");
                    $find("<%= BreachRadColourPicker.ClientID%>").set_selectedColor("#ffffff");
                    $find("<%= txtHL7Code.ClientID%>").set_value("");
                }
                oWnd.show();
                return false;
            }

            function closeAddItemWindow() {
                var oWnd = $find("<%= AddNewItemRadWindow.ClientID%>");
                if (oWnd != null)
                    oWnd.close();
                return false;
            }

            function refreshGrid(arg) {
               if (!arg) {
                    var masterTable = $find("<%= BookingBreachRadGrid.ClientID %>").get_masterTableView();
                    masterTable.fireCommand("Rebind", arg);
                }
                else {
                    var masterTable = $find("<%= BookingBreachRadGrid.ClientID %>").get_masterTableView();
                    masterTable.fireCommand("RebindAndNavigate", arg);
                }
            }

             function linkHL7Code() {
                var ownd = radopen("BookingStatusLinkHL7Code.aspx", "windowLinkHL7Code", 720, 655);
                ownd.set_visibleStatusbar(false);
                return false;
            }


            function AddNewItemSave(sender, args) {
               let breachDays =  $("#<%=BreachDaysRadNumericTextBox.ClientID%>").val()
                if (breachDays == '') {
                    var notification = $find("<%=RadNotification1.ClientID%>");
                    notification.set_text(" Breach Days field cannot be left blank")
                    notification.show();
                    args.set_cancel(true);
                }
            
            }
        </script>

    </telerik:RadScriptBlock>

</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyContentPlaceHolder" runat="Server">
    <asp:HiddenField ID="hiddenItemId" runat="server" />
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
<%--    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />--%>
            <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Skin="Metro" Position="Center" Width="400" Height="150" BorderStyle="Ridge" BorderColor="Red" AutoCloseDelay="0" ShowCloseButton="true" TitleIcon="none" ContentIcon="Warning" EnableShadow="true" EnableRoundedCorners="true" />

    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
    </telerik:RadAjaxLoadingPanel>

    <div class="optionsHeading">
        <asp:Label ID="HeadingLabel" runat="server" Text="Booking / Breach Status and Colours"></asp:Label>
    </div>

    <telerik:RadFormDecorator runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />

    <asp:ObjectDataSource ID="BookingBreachObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetBookingBreachStatus">
        <UpdateParameters>
            <asp:Parameter Name="StatusId" DbType="Int32" DefaultValue="" />
            <asp:Parameter Name="Description" DbType="String" DefaultValue="" />
            <asp:Parameter Name="GI" DbType="Boolean" DefaultValue="False" />
            <asp:Parameter Name="nonGI" DbType="Boolean" DefaultValue="False" />
            <asp:Parameter Name="BreachDays" DbType="Int32" DefaultValue="0" />
            <asp:Parameter Name="ForeColor" DbType="String" DefaultValue="" />
            <asp:Parameter Name="HL7Code" DbType="String" DefaultValue="" />
        </UpdateParameters>
        <InsertParameters>
            <asp:Parameter Name="StatusId" DbType="Int32" DefaultValue="" />
            <asp:Parameter Name="Description" DbType="String" DefaultValue="" />
            <asp:Parameter Name="GI" DbType="Boolean" DefaultValue="False" />
            <asp:Parameter Name="nonGI" DbType="Boolean" DefaultValue="False" />
            <asp:Parameter Name="BreachDays" DbType="Int32" DefaultValue="0" />
            <asp:Parameter Name="ForeColor" DbType="String" DefaultValue="" />
            <asp:Parameter Name="HL7Code" DbType="String" DefaultValue="" />
        </InsertParameters>
    </asp:ObjectDataSource>

    <div id="FormDiv" runat="server" style="margin-top: 10px; width: 700px;">
        <div style="margin-top: 5px; margin-left: 10px; height: 100px;" class="optionsBodyText">

            <asp:Panel ID="Panel1" runat="server" Skin="Metro" GroupingText="Please Note">
                <table style="width: 100%; padding-left: 10px;">
                    <tr>
                        <td style="padding-top: 10px; padding-left: 10px; width: 10%;"></td>
                        <td style="padding-top: 10px;">
                            <asp:Label runat="server" ID="BookingNotes">Use this screen to change the name of the booking/slot and the colour. <br />
                        NB Routine and Inpatient names cannot be changed.
                            </asp:Label>
                        </td>
                    </tr>
                </table>

            </asp:Panel>
        </div>
        <div id="Div1" runat="server" style="margin-top: 10px; width: 700px; padding-left: 10px; font-family: Calibri; font-size: 11pt;">
            <asp:Panel runat="server" Skin="Metro" ID="BookingTypes">
                <telerik:RadGrid ID="BookingBreachRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false" AllowSorting="true"
                    DataSourceID="BookingBreachObjectDataSource" Skin="Metro" PageSize="50" AllowPaging="true" Style="margin-bottom: 10px; width: 100%; height: 500px;">
                    <HeaderStyle Font-Bold="true" />
                    <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="StatusId" DataKeyNames="StatusID" TableLayout="Fixed" EnableNoRecordsTemplate="true" CssClass="MasterClass">
                  
                        <Columns>
                            <telerik:GridTemplateColumn UniqueName="TemplateColumn" HeaderStyle-Width="100px">
                                <ItemTemplate>
                                    <asp:LinkButton ID="EditLinkButton" runat="server" Text="Edit" ToolTip="Edit this item" Font-Italic="true"></asp:LinkButton>
                                </ItemTemplate>
                                <HeaderTemplate>
                                    <telerik:RadButton ID="AddNewItemButton" runat="server" Text="Add new item" Skin="Metro" OnClientClicked="openAddItemWindow" AutoPostBack="false" />                                    
                                </HeaderTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridBoundColumn DataField="Description" HeaderText="Type of Booking" HeaderStyle-Width="200px" />
                            <telerik:GridTemplateColumn HeaderText="Colour" HeaderStyle-Width="60px" UniqueName="Colour" ItemStyle-HorizontalAlign="Center">
                                <ItemTemplate>
                                    <asp:Label ID="ColourLabel" runat="server" Width="50" Height="12"></asp:Label>
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridBoundColumn DataField="BreachDays" HeaderText="Breach Days" HeaderStyle-Width="75px" />
                            <telerik:GridBoundColumn DataField="HL7Code" HeaderText="HL7Code" HeaderStyle-Width="100px" />
                        </Columns>
                    </MasterTableView>
                    <ClientSettings>
                        <Scrolling AllowScroll="true" UseStaticHeaders="true" />
                    </ClientSettings>
                </telerik:RadGrid>

                <telerik:RadButton ID="btnLinkHL7Code" runat="server" Text="Link Hospital HL7Code" Skin="Metro" OnClientClicked="linkHL7Code" AutoPostBack="false" />
            </asp:Panel>
            <telerik:RadWindowManager ID="RadWindowManager2" runat="server">
                <Windows>
                    <telerik:RadWindow ID="ItemListDialog" runat="server" Title="Editing record"
                        Width="800px" Height="500px" Left="150px" ReloadOnShow="true" ShowContentDuringLoad="false"
                        Modal="true" VisibleStatusbar="false" Skin="Metro">
                    </telerik:RadWindow>
                </Windows>
            </telerik:RadWindowManager>
        </div>
        <telerik:RadWindowManager ID="AddNewItemRadWindowManager" runat="server" ShowContentDuringLoad="false"
            Style="z-index: 7001" Behaviors="Close, Move" Skin="Metro" EnableShadow="true" Modal="true" ReloadOnShow="true">
            <Windows>
                <telerik:RadWindow ID="AddNewItemRadWindow" runat="server" ReloadOnShow="true" Title="New Item" VisibleStatusbar="false"
                    KeepInScreenBounds="true" Width="470px" Height="300px" Style="z-index: 7001">
                    <ContentTemplate>
                        <table cellspacing="3" cellpadding="3">
                            <tr>
                                <td id="tdItemTitle">
                                    <b>Add new item</b>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <table>
                                        <tr>
                                            <td>Description :
                                            </td>
                                            <td colspan="3">
                                                <telerik:RadTextBox ID="DescriptionRadTextBox" runat="Server" Width="280px" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>Breach Days :
                                            </td>
                                            <td colspan="3">
                                                <telerik:RadNumericTextBox runat="server" ID="BreachDaysRadNumericTextBox" Width="85px" MinValue="0" MaxValue="1000" Skin="Windows7" NumberFormat-DecimalDigits="0" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>Colour :
                                            </td>
                                            <td>
                                                <telerik:RadColorPicker ID="BreachRadColourPicker" runat="server" ShowIcon="true" PaletteModes="WebPalette" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                HL7Code :
                                            </td>
                                            <td>
                                                <telerik:RadTextBox ID="txtHL7Code" runat="Server" Width="280px" />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <div id="buttonsdiv" style="height: 10px; padding-top: 16px; vertical-align: central;">
                                        <telerik:RadButton ID="AddNewItemSaveRadButton" runat="server" Text="Save" Skin="Web20"  OnClientClicked="AddNewItemSave"/>
                                        <telerik:RadButton ID="AddNewItemCancelRadButton" runat="server" Text="Cancel" Skin="Web20" OnClientClicked="closeAddItemWindow" />
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </ContentTemplate>
                </telerik:RadWindow>
            </Windows>
        </telerik:RadWindowManager>
    </div>
</asp:Content>
