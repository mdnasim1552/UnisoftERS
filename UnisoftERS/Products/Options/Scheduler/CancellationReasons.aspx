<%@ Page Language="vb" MasterPageFile="~/Templates/Scheduler.master" AutoEventWireup="false" CodeBehind="CancellationReasons.aspx.vb" Inherits="UnisoftERS.CancellationReasons" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContentPlaceHolder" runat="Server">

    <title>Cancellation Reasons</title>
    <script type="text/javascript" src="../../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
    </style>

    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">

            //Close a rad window
            function CloseConfigWindow() {

              
                var oWnd = $find("<%= CancelReasonsConfigWindow.ClientID %>");
                if (oWnd != null)
                    oWnd.close();
                else {
                    oWnd = $find("<%= LockReasonsRadWindow.ClientID %>");
                    if (oWnd != null)
                        oWnd.close();
                }
            }

            function CloseListLockReasonsConfigWindow() {
                var oWnd = $find("<%= ListLockReasonsRadWindow.ClientID %>");
                if (oWnd != null)
                    oWnd.close();
            }

            function CloseLockReasonsConfigWindow() {
                var oWnd = $find("<%= LockReasonsRadWindow.ClientID %>");
                if (oWnd != null)
                    oWnd.close();
            }


            function CloseLetterEditReasonWindow() {
                var oWnd = $find("<%= LetterEditReasonWindow.ClientID %>");
                if (oWnd != null)
                    oWnd.close();
            }

            function addCancelReasons(rowIndex) {

                let cancellText = $find('<%=ReasonTypeRadComboBox.ClientID %>').get_text();
                var oWnd = $find("<%= CancelReasonsConfigWindow.ClientID%>");

                let reasonId;
                if (rowIndex > -1) {
                    let RadGrid;
                    if (cancellText == 'Cancellation reasons') {
                        RadGrid = $find('<%=CancelReasonsRadGrid.ClientID %>');
                        reasonId =  'CancelReasonId'
                    }
                    else {
                        RadGrid = $find('<%=ShecheduleReasonsRadGrid.ClientID %>');
                        reasonId = 'ListCancelReasonId'
                    }
                    var masterTableView = RadGrid.get_masterTableView();
                    var CancelReasonDataItems = masterTableView.get_dataItems()[rowIndex];
                    //get the datakeyname
                    var CancelReasonID = CancelReasonDataItems.getDataKeyValue(reasonId);
                    var Code = CancelReasonDataItems.getDataKeyValue("Code");
                    var Detail = CancelReasonDataItems.getDataKeyValue("Detail");
                    var CancelledByHospital = CancelReasonDataItems.getDataKeyValue("CancelledByHospital");


                    $find('<% =AddNewCancelReasonSaveRadButton.ClientID%>').set_text("Update");
                    oWnd.set_title('Edit cancellation reason');
                    $find('<% =CodeTextBox.ClientID%>').set_value(Code);
                    $find('<% =DetailTextBox.ClientID%>').set_value(Detail);

                    if (CancelledByHospital == "True") {
                        $find('<%= CancelledByHospitalRadCheckBox.ClientID%>').set_checked(true);
                    }
                    else {
                        $find('<%= CancelledByHospitalRadCheckBox.ClientID%>').set_checked(false);
                    };

                    $find('<%= CancelReasonIDText.ClientID%>').set_value(CancelReasonID);
                } else {
                    //document.getElementById("tdItemTitle").innerHTML = '<b>Add new item</b>';
                    $find('<%= CancelReasonIDText.ClientID%>').set_value(0);
                    $find('<% =AddNewCancelReasonSaveRadButton.ClientID%>').set_text("Save");
                    oWnd.set_title('New Item');
                    $find("<%= CodeTextBox.ClientID%>").set_value("");
                    $find('<%= DetailTextBox.ClientID%>').set_value("");
                    $find('<%= CancelledByHospitalRadCheckBox.ClientID%>').set_checked(false);
                }
                oWnd.show();
                return false;
            }

            function addListLockReasons() {
                var oWnd = $find("<%= ListLockReasonsRadWindow.ClientID%>");
                oWnd.set_title('Add list lock reason');
                oWnd.show();

                $find("<%= ListLockReasonRadTextBox.ClientID%>").set_value("");
                $find('<%= IsListLockReasonRadioButtonList.ClientID%>').set_checked(false);


                return false;
            }

            function addLockReasons() {
                var oWnd = $find("<%= LockReasonsRadWindow.ClientID%>");
                oWnd.set_title('Add diary lock reason');
                oWnd.show();

                $find("<%= DiaryLockReasonRadTextBox.ClientID%>").set_value("");
                $find('<%= IsLockReasonRadioButtonList.ClientID%>').set_checked(false);
                return false;
            }

            function AddLetterEditReasons() {
                var oWnd = $find("<%= LetterEditReasonWindow.ClientID%>");
                oWnd.set_title('Add Letter Edit reason');
                oWnd.show();
                $find("<%= LetterEditReasonText.ClientID%>").set_value("");
                return false;
            }

            function editListLockReason(rowIndex) {
                var oWnd = $find("<%= ListLockReasonsRadWindow.ClientID%>");
                oWnd.set_title('Edit list lock reason');
                oWnd.show();

                var gvID = $find('<%=ListLockReasonsRadGrid.ClientID %>');
                var masterTableView = gvID.get_masterTableView();
                var LockReasonDataItems = masterTableView.get_dataItems()[rowIndex];

                //get the datakeyname
                var lockReasonID = LockReasonDataItems.getDataKeyValue("ListLockReasonId");
                var reason = LockReasonDataItems.getDataKeyValue("Reason");
                var isLockReason = LockReasonDataItems.getDataKeyValue("IsLockReason");
                var isUnlockReason = LockReasonDataItems.getDataKeyValue("IsUnlockReason");

                $('#<%=ReasonsIdHiddenField.ClientID%>').val(lockReasonID);
                $find('<% =ListLockReasonRadTextBox.ClientID%>').set_value(reason);

                if (isLockReason == "True") {
                    $('#<%= IsListLockReasonRadioButtonList.ClientID%>').find("input[value='1']").prop("checked", true);

                }
                if (isUnlockReason == "True") {
                    $('#<%= IsListLockReasonRadioButtonList.ClientID%>').find("input[value='0']").prop("checked", true);
                }


                return false;
            }

            function editLockReason(rowIndex) {
                var oWnd = $find("<%= LockReasonsRadWindow.ClientID%>");
                oWnd.set_title('Edit diary lock reason');
                oWnd.show();

                var gvID = $find('<%=DiaryLockReasonsRadGrid.ClientID %>');
                var masterTableView = gvID.get_masterTableView();
                var LockReasonDataItems = masterTableView.get_dataItems()[rowIndex];

                //get the datakeyname
                var lockReasonID = LockReasonDataItems.getDataKeyValue("DiaryLockReasonId");
                var reason = LockReasonDataItems.getDataKeyValue("Reason");
                var isLockReason = LockReasonDataItems.getDataKeyValue("IsLockReason");
                var isUnlockReason = LockReasonDataItems.getDataKeyValue("IsUnlockReason");

                $('#<%=ReasonsIdHiddenField.ClientID%>').val(lockReasonID);
                $find('<% =DiaryLockReasonRadTextBox.ClientID%>').set_value(reason);

                if (isLockReason == "True") {
                    $('#<%= IsLockReasonRadioButtonList.ClientID%>').find("input[value='1']").prop("checked", true);

                }
                if (isUnlockReason == "True") {
                    $('#<%= IsLockReasonRadioButtonList.ClientID%>').find("input[value='0']").prop("checked", true);
                }


                return false;
            }


            function editLetterEditReason(rowIndex) {
                var oWnd = $find("<%= LetterEditReasonWindow.ClientID%>");
                oWnd.set_title('Edit Letter Edit reason');
                oWnd.show();

                var gvID = $find('<%=LetterEditReasonsGrid.ClientID %>');
                var masterTableView = gvID.get_masterTableView();
                var etterEditReasonDataItems = masterTableView.get_dataItems()[rowIndex];

                //get the datakeyname
                var LetterEditReasonId = etterEditReasonDataItems.getDataKeyValue("LetterEditReasonId");
                var reason = etterEditReasonDataItems.getDataKeyValue("Reason");

                $('#<%=hdnLetterEditReasonId.ClientID%>').val(LetterEditReasonId);
                $find('<% =LetterEditReasonText.ClientID%>').set_value(reason);
                return false;
            }

            function Show() {
                if (confirm("Are you sure?")) {
                    return true;
                }
                else {
                    return false;
                }
            }
            function AddNewCancelReasonSave(sender, args) {
                let text = $('#<%=DetailTextBox.ClientID%>').val();
                if (text == "") {
                    $('#<%=DetailTextBox.ClientID%>').css('border-color', 'red');
                    args.set_cancel(true);
                }
            }

        </script>
    </telerik:RadScriptBlock>

</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyContentPlaceHolder" runat="Server">
    <!-- FORM All controls in here -->

    <asp:HiddenField ID="hiddenShowSuppressedItems" runat="server" Value="0" />
    <telerik:RadFormDecorator ID="RadFormDecorator2" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
    <telerik:RadNotification ID="FailedNotification" AutoCloseDelay="0" ShowCloseButton="true" runat="server" VisibleOnPageLoad="false" Skin="Metro" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>" ForeColor="Red" Position="Center" />

    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
    </telerik:RadAjaxLoadingPanel>
    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />

    <div>
    </div>

    <div class="optionsHeading">
        <asp:Label ID="HeadingLabel" runat="server" Text="Cancellation/Lock/Letter Edit Reasons"></asp:Label>
    </div>

    <div id="FilterDiv" runat="server" class="optionsBodyText" style="margin: 10px;">
        Type:&nbsp;<telerik:RadComboBox ID="ReasonTypeRadComboBox" runat="server" Width="270px" AutoPostBack="true" CssClass="filterDDL" OnSelectedIndexChanged="ReasonTypeRadComboBox_SelectedIndexChanged">
            <Items>
                <telerik:RadComboBoxItem Text="Cancellation reasons" Value="0" />
                <telerik:RadComboBoxItem Text="Diary lock reasons" Value="1" />
                <telerik:RadComboBoxItem Text="Letter edit reasons" Value="2" />
                <telerik:RadComboBoxItem Text="Slot lock reasons" Value="3" /> <%-- modified by Ferdowsi (List to slot), TFS - 4425--%>
                <telerik:RadComboBoxItem Text="List cancellation Reasons" Value="4" />
            </Items>
        </telerik:RadComboBox>
    </div>

    <div id="FormDiv" runat="server" style="margin-top: 10px;">
        <div style="margin-left: 10px; margin-top: 20px;" class="rptText">
            <asp:Panel ID="pnlCancellationReasons" runat="server">
                <telerik:RadGrid ID="CancelReasonsRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false" AllowSorting="true"
                    DataSourceID="CancelReasonsDataSource"
                    Skin="Metro" PageSize="50" AllowPaging="true" Style="margin-bottom: 10px; width: 75%; height: 500px;">
                    <HeaderStyle Font-Bold="true" />
                    <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="CancelReasonId,Code,Detail,CancelledByHospital" DataKeyNames="CancelReasonId,Code,Detail,CancelledByHospital" TableLayout="Fixed"
                        EnableNoRecordsTemplate="true" CssClass="MasterClass">
                        <Columns>
                            <telerik:GridTemplateColumn UniqueName="EditLinkButtonColumn" HeaderStyle-Width="65px">
                                <ItemTemplate>
                                    <asp:LinkButton ID="EditLinkButton" runat="server" Text="Edit" ToolTip="Edit Cancellation Reason" Font-Italic="true"></asp:LinkButton>
                                    &nbsp;&nbsp;

                                        <asp:LinkButton ID="SuppressLinkButton" runat="server" Text="Suppress" ToolTip="Suppress this record"
                                            Enabled="true" OnClientClick="return Show()"
                                            CommandName="SuppressCancelReason" Font-Italic="true"></asp:LinkButton>
                                </ItemTemplate>
                                <HeaderTemplate>
                                    <telerik:RadButton ID="AddNewCancelReasonsButton" runat="server" Text="Add New" Skin="Metro" AutoPostBack="false" OnClientClicked="addCancelReasons"></telerik:RadButton>
                                </HeaderTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridBoundColumn DataField="CancelReasonId" Visible="false" />
                            <telerik:GridBoundColumn DataField="Code" HeaderText="Cancellation Code" HeaderStyle-Width="200px" Visible="false" />
                            <telerik:GridBoundColumn DataField="Detail" HeaderText="Cancellation Reason" HeaderStyle-Width="200px" />
                            <telerik:GridTemplateColumn ItemStyle-HorizontalAlign="Center" HeaderText="Cancelled by Hospital" HeaderStyle-Width="50px" HeaderStyle-HorizontalAlign="Center" Visible="false">
                                <ItemTemplate>
                                    <asp:CheckBox ID="HospitalCancelledCheckBox" runat="server" Checked='<%# Bind("CancelledByHospital")%>' Enabled="false" />
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                        </Columns>
                        <NoRecordsTemplate>
                            <div style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;" id="NoRecordsDiv" runat="server">
                                No cancellation reasons found
                            </div>
                        </NoRecordsTemplate>
                    </MasterTableView>
                    <PagerStyle Mode="NumericPages"></PagerStyle>

                    <ClientSettings>
                        <Scrolling AllowScroll="true" UseStaticHeaders="true" />
                        <Selecting AllowRowSelect="true" />
                    </ClientSettings>
                </telerik:RadGrid>
            </asp:Panel>

            <asp:Panel ID="pnlTemplateReasons" runat="server" Visible="false">
                <telerik:RadGrid ID="ShecheduleReasonsRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false" AllowSorting="true"  
                    DataSourceID="GetScheduleListReasonsDataSource"
                    Skin="Metro" PageSize="50" AllowPaging="true" Style="margin-bottom: 10px; width: 75%; height: 500px;">
                    <HeaderStyle Font-Bold="true" />
                    <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="ListCancelReasonId,Code,Detail,CancelledByHospital" DataKeyNames="ListCancelReasonId,Code,Detail,CancelledByHospital" TableLayout="Fixed"
                        EnableNoRecordsTemplate="true" CssClass="MasterClass">
                        <Columns>
                            <telerik:GridTemplateColumn UniqueName="EditLinkButtonColumn" HeaderStyle-Width="65px">
                                <ItemTemplate>
                                    <asp:LinkButton ID="ListReasonsEditButton" runat="server" Text="Edit" ToolTip="Edit Cancellation Reason" Font-Italic="true"></asp:LinkButton>
                                    &nbsp;&nbsp;
                                    <asp:LinkButton ID="ScheduleSuppressLinkButton" runat="server" Text="Suppress" ToolTip="Suppress this record"
                                    Enabled="true" OnClientClick="return Show()"
                                     CommandName="ShecheduleReasonsRadGrid" Font-Italic="true"></asp:LinkButton>
                                </ItemTemplate>
                                <HeaderTemplate>
                                    <telerik:RadButton ID="AddNewCancelReasonsButton" runat="server" Text="Add New" Skin="Metro" AutoPostBack="false" OnClientClicked="addCancelReasons"></telerik:RadButton>
                                </HeaderTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridBoundColumn DataField="ListCancelReasonId" Visible="false" />
                            <telerik:GridBoundColumn DataField="Code" HeaderText="Cancellation Code" HeaderStyle-Width="200px" Visible="false" />
                            <telerik:GridBoundColumn DataField="Detail" HeaderText="Cancellation Reason" HeaderStyle-Width="200px" />
                            <telerik:GridTemplateColumn ItemStyle-HorizontalAlign="Center" HeaderText="Cancelled by Hospital" HeaderStyle-Width="50px" HeaderStyle-HorizontalAlign="Center" Visible="false">
                                <ItemTemplate>
                                    <asp:CheckBox ID="HospitalCancelledCheckBox" runat="server" Checked='<%# Bind("CancelledByHospital")%>' Enabled="false" />
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                        </Columns>
                        <NoRecordsTemplate>
                            <div style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;" id="NoRecordsDiv" runat="server">
                                No cancellation reasons found
                            </div>
                        </NoRecordsTemplate>
                    </MasterTableView>
                    <PagerStyle Mode="NumericPages"></PagerStyle>

                    <ClientSettings>
                        <Scrolling AllowScroll="true" UseStaticHeaders="true" />
                        <Selecting AllowRowSelect="true" />
                    </ClientSettings>
                </telerik:RadGrid>
            </asp:Panel>
            <asp:Panel ID="pnlDiaryLockReasons" runat="server" Visible="false">
                <telerik:RadGrid ID="DiaryLockReasonsRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false" AllowSorting="true" DataSourceID="DiaryLockReasonsObjectDataSource"
                    Skin="Metro" PageSize="50" AllowPaging="true" Style="margin-bottom: 10px; width: 75%; height: 500px;"
                    OnItemCreated="DiaryLockReasonsRadGrid_ItemCreated">
                    <HeaderStyle Font-Bold="true" />
                    <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="DiaryLockReasonId,Reason,IsLockReason,IsUnlockReason" DataKeyNames="DiaryLockReasonId,Reason,IsLockReason,IsUnlockReason" TableLayout="Fixed"
                        EnableNoRecordsTemplate="true" CssClass="MasterClass">
                        <Columns>
                            <telerik:GridTemplateColumn UniqueName="EditLinkButtonColumn" HeaderStyle-Width="65px">
                                <ItemTemplate>
                                    <asp:LinkButton ID="EditLockReasonLinkButton" runat="server" Text="Edit" ToolTip="Edit Lock Reason" Font-Italic="true"></asp:LinkButton>
                                    &nbsp;&nbsp;

                                        <asp:LinkButton ID="SuppressLockReasonLinkButton" runat="server" Text="Suppress" ToolTip="Suppress Lock Reason" OnClientClick="return Show()"
                                            CommandName="SuppressLockReason" Font-Italic="true"></asp:LinkButton>

                                </ItemTemplate>
                                <HeaderTemplate>
                                    <telerik:RadButton ID="AddNewLockReasonsButton" runat="server" Text="Add New" Skin="Metro" AutoPostBack="false" OnClientClicked="addLockReasons"></telerik:RadButton>
                                </HeaderTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridBoundColumn DataField="Reason" HeaderText="Lock reason" HeaderStyle-Width="200px" />
                            <telerik:GridTemplateColumn ItemStyle-HorizontalAlign="Center" HeaderText="Locking reason" HeaderStyle-Width="30px" HeaderStyle-HorizontalAlign="Center">
                                <ItemTemplate>
                                    <asp:CheckBox ID="IsLockReasonCheckBox" runat="server" Checked='<%# Bind("IsLockReason")%>' Enabled="false" />
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridTemplateColumn ItemStyle-HorizontalAlign="Center" HeaderText="Unlocking Reason" HeaderStyle-Width="30px" HeaderStyle-HorizontalAlign="Center">
                                <ItemTemplate>
                                    <asp:CheckBox ID="IsUnlockCheckBox" runat="server" Checked='<%# Bind("IsUnlockReason")%>' Enabled="false" />
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                        </Columns>
                        <NoRecordsTemplate>
                            <div style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;" id="NoRecordsDiv" runat="server">
                                No lock reasons found
                            </div>
                        </NoRecordsTemplate>
                    </MasterTableView>
                    <PagerStyle Mode="NumericPages"></PagerStyle>

                    <ClientSettings>
                        <Scrolling AllowScroll="true" UseStaticHeaders="true" />
                        <Selecting AllowRowSelect="true" />
                    </ClientSettings>
                </telerik:RadGrid>
            </asp:Panel>
            <asp:Panel ID="pnlLetterEditReasons" runat="server" Visible="false">
                <telerik:RadGrid ID="LetterEditReasonsGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false" AllowSorting="true"
                    DataSourceID="LetterEditReasonsDataSource"
                    Skin="Metro" PageSize="50" AllowPaging="true" Style="margin-bottom: 10px; width: 75%; height: 500px;" OnItemCreated="LetterEditReasonsGrid_ItemCreated">
                    <HeaderStyle Font-Bold="true" />
                    <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="LetterEditReasonId,Reason,Suppressed" DataKeyNames="LetterEditReasonId,Reason,Suppressed" TableLayout="Fixed"
                        EnableNoRecordsTemplate="true" CssClass="MasterClass">
                        <Columns>
                            <telerik:GridTemplateColumn UniqueName="EditLinkButtonColumn" HeaderStyle-Width="65px">

                                <ItemTemplate>
                                    <asp:LinkButton ID="LetterEditLinkButton" runat="server" Text="Edit" ToolTip="Edit Letter Edit Reason" Font-Italic="true"></asp:LinkButton>
                                    &nbsp;&nbsp;

                                        <asp:LinkButton ID="SuppressLetterEditReasonLinkButton" runat="server" Text="Suppress" ToolTip="Suppress Edit Reason" OnClientClick="return Show()"
                                            CommandName="SuppressEditLetterReason" Font-Italic="true"></asp:LinkButton>
                                </ItemTemplate>
                                <HeaderTemplate>
                                    <telerik:RadButton ID="AddNewLetterEditReasonsButton" runat="server" Text="Add New" Skin="Metro" AutoPostBack="false" OnClientClicked="AddLetterEditReasons"></telerik:RadButton>
                                </HeaderTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridBoundColumn DataField="LetterEditReasonId" Visible="false" />
                            <telerik:GridBoundColumn DataField="Reason" HeaderText="Reason" HeaderStyle-Width="200px" />
                        </Columns>
                        <NoRecordsTemplate>
                            <div style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;" id="NoRecordsDiv" runat="server">
                                No Letter edit reasons found
                            </div>
                        </NoRecordsTemplate>
                    </MasterTableView>
                    <PagerStyle Mode="NumericPages"></PagerStyle>

                    <ClientSettings>
                        <Scrolling AllowScroll="true" UseStaticHeaders="true" />
                        <Selecting AllowRowSelect="true" />
                    </ClientSettings>
                </telerik:RadGrid>
            </asp:Panel>
            <asp:Panel ID="pnlListLockReasons" runat="server" Visible="false">
                <telerik:RadGrid ID="ListLockReasonsRadGrid" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false" AllowSorting="true" DataSourceID="ListLockReasonsObjectDataSource"
                    Skin="Metro" PageSize="50" AllowPaging="true" Style="margin-bottom: 10px; width: 75%; height: 500px;"
                    OnItemCreated="ListLockReasonsRadGrid_ItemCreated">
                    <HeaderStyle Font-Bold="true" />
                    <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="ListLockReasonId,Reason,IsLockReason,IsUnlockReason" DataKeyNames="ListLockReasonId,Reason,IsLockReason,IsUnlockReason" TableLayout="Fixed"
                        EnableNoRecordsTemplate="true" CssClass="MasterClass">
                        <Columns>
                            <telerik:GridTemplateColumn UniqueName="EditListLinkButtonColumn" HeaderStyle-Width="65px">
                                <ItemTemplate>
                                    <asp:LinkButton ID="EditListLockReasonLinkButton" runat="server" Text="Edit" ToolTip="Edit Lock Reason" Font-Italic="true"></asp:LinkButton>
                                    &nbsp;&nbsp;

                                        <asp:LinkButton ID="SuppressListLockReasonLinkButton" runat="server" Text="Suppress" ToolTip="Suppress Lock Reason" OnClientClick="return Show()"
                                            CommandName="SuppressListLockReason" Font-Italic="true"></asp:LinkButton>

                                </ItemTemplate>
                                <HeaderTemplate>
                                    <telerik:RadButton ID="AddNewLockReasonsButton" runat="server" Text="Add New" Skin="Metro" AutoPostBack="false" OnClientClicked="addListLockReasons"></telerik:RadButton>
                                </HeaderTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridBoundColumn DataField="Reason" HeaderText="Lock reason" HeaderStyle-Width="200px" />
                            <telerik:GridTemplateColumn ItemStyle-HorizontalAlign="Center" HeaderText="Locking reason" HeaderStyle-Width="30px" HeaderStyle-HorizontalAlign="Center">
                                <ItemTemplate>
                                    <asp:CheckBox ID="IsLockReasonCheckBox" runat="server" Checked='<%# Bind("IsLockReason")%>' Enabled="false" />
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridTemplateColumn ItemStyle-HorizontalAlign="Center" HeaderText="Unlocking Reason" HeaderStyle-Width="30px" HeaderStyle-HorizontalAlign="Center">
                                <ItemTemplate>
                                    <asp:CheckBox ID="IsUnlockCheckBox" runat="server" Checked='<%# Bind("IsUnlockReason")%>' Enabled="false" />
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                        </Columns>
                        <NoRecordsTemplate>
                            <div style="margin-top: 10px; margin-bottom: 10px; margin-left: 5px;" id="NoRecordsDiv" runat="server">
                                No lock reasons found
                            </div>
                        </NoRecordsTemplate>
                    </MasterTableView>
                    <PagerStyle Mode="NumericPages"></PagerStyle>

                    <ClientSettings>
                        <Scrolling AllowScroll="true" UseStaticHeaders="true" />
                        <Selecting AllowRowSelect="true" />
                    </ClientSettings>
                </telerik:RadGrid>
            </asp:Panel>

        </div>
        <asp:HiddenField ID="ReasonsIdHiddenField" runat="server" />
        <asp:HiddenField ID="hdnLetterEditReasonId" runat="server" />

        <telerik:RadWindowManager ID="RadWindowManager1" runat="server" Skin="Metro" Modal="true" VisibleStatusbar="false">
            <Windows>
                <telerik:RadWindow ID="CancelReasonsConfigWindow" runat="server" ReloadOnShow="true" Width="500" Height="220" KeepInScreenBounds="true" Skin="Metro">
                    <ContentTemplate>
                        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="WindowsDiv" Skin="Metro" />

                        <div id="WindowsDiv">
                            <telerik:RadTextBox ID="CancelReasonIDText" runat="server" Style="visibility: hidden" />
                            <!-- Style="visibility:hidden" />-->
                            <table style="width: 100%; padding: 10px;">
                                <tr>
                                    <td>
                                        <asp:Label ID="CodeLabel" runat="server" Text="Code" /></td>
                                    <td>
                                        <telerik:RadTextBox ID="CodeTextBox" runat="server" Style="z-index: 1;" /></td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:Label ID="DetailLabel" runat="server" Text="Reason" /></td>
                                    <td>
                                        <telerik:RadTextBox ID="DetailTextBox" runat="server" Style="z-index: 2;" /></td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:Label ID="CancelledByHospitalLabel" runat="server" Text="Cancelled by hospital" /></td>
                                    <td>
                                        <telerik:RadCheckBox runat="server" ID="CancelledByHospitalRadCheckBox" AutoPostBack="false" />
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="3" style="padding-top: 10px; text-align: right;"><%-- Change to number of columns --%>
                                        <div id="buttonsdiv" style="height: 10px; padding-top: 6px; vertical-align: central;">
                                            <telerik:RadButton ID="AddNewCancelReasonSaveRadButton" runat="server" Text="Save" Skin="Metro" OnClientClicked="AddNewCancelReasonSave"
                                                OnClick="AddNewCancelReasonSaveRadButton_Click" />
                                            <telerik:RadButton ID="AddNewCancelReasonCancelRadButton" runat="server" Text="Cancel" Skin="Metro"
                                                OnClientClicked="CloseConfigWindow" AutoPostBack="false" />
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </div>
                        <!-- Data goes here -->
                    </ContentTemplate>
                </telerik:RadWindow>
                <telerik:RadWindow ID="ListLockReasonsRadWindow" runat="server" ReloadOnShow="true" Width="500" Height="220" KeepInScreenBounds="true" Skin="Metro">
                    <ContentTemplate>
                        <telerik:RadFormDecorator runat="server" DecoratedControls="All" DecorationZoneID="lockwindow" Skin="Metro" />

                        <div id="listlockwindow">
                            <table style="width: 100%; padding: 10px;">
                                <tr>
                                    <td>
                                        <asp:Label runat="server" Text="Reason" /></td>
                                    <td>
                                        <telerik:RadTextBox ID="ListLockReasonRadTextBox" runat="server" Width="370" /></td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <asp:RadioButtonList ID="IsListLockReasonRadioButtonList" runat="server">
                                            <asp:ListItem Text="Lock reason" Value="1" />
                                            <asp:ListItem Text="Unlock reason" Value="0" />
                                        </asp:RadioButtonList>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" style="padding-top: 50px; text-align: right;">
                                        <div class="buttonsdiv" style="height: 10px; padding-top: 6px; vertical-align: central;">
                                            <telerik:RadButton ID="SaveListLockReasonRadButton" runat="server" Text="Save" Skin="Metro"
                                                OnClick="SaveListLockReasonRadButton_Click" />
                                            <telerik:RadButton ID="CancelSaveListLockReasonRadButton" runat="server" Text="Cancel" Skin="Metro"
                                                OnClientClicked="CloseListLockReasonsConfigWindow" AutoPostBack="false" />
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </div>
                        <!-- Data goes here -->
                    </ContentTemplate>
                </telerik:RadWindow>
                <telerik:RadWindow ID="LockReasonsRadWindow" runat="server" ReloadOnShow="true" Width="500" Height="220" KeepInScreenBounds="true" Skin="Metro">
                    <ContentTemplate>
                        <telerik:RadFormDecorator ID="RadFormDecorator3" runat="server" DecoratedControls="All" DecorationZoneID="lockwindow" Skin="Metro" />

                        <div id="lockwindow">
                            <table style="width: 100%; padding: 10px;">
                                <tr>
                                    <td>
                                        <asp:Label ID="Label1" runat="server" Text="Reason" /></td>
                                    <td>
                                        <telerik:RadTextBox ID="DiaryLockReasonRadTextBox" runat="server" Width="370" /></td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <asp:RadioButtonList ID="IsLockReasonRadioButtonList" runat="server">
                                            <asp:ListItem Text="Lock reason" Value="1" />
                                            <asp:ListItem Text="Unlock reason" Value="0" />
                                        </asp:RadioButtonList>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2" style="padding-top: 50px; text-align: right;"><%-- Change to number of columns --%>
                                        <div class="buttonsdiv" style="height: 10px; padding-top: 6px; vertical-align: central;">
                                            <telerik:RadButton ID="SaveLockReasonRadButton" runat="server" Text="Save" Skin="Metro"
                                                OnClick="SaveLockReasonRadButton_Click" />
                                            <telerik:RadButton ID="CancelSaveLockReasonRadButton" runat="server" Text="Cancel" Skin="Metro"
                                                OnClientClicked="CloseLockReasonsConfigWindow" AutoPostBack="false" />
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </div>
                        <!-- Data goes here -->
                    </ContentTemplate>
                </telerik:RadWindow>
                <telerik:RadWindow ID="LetterEditReasonWindow" runat="server" ReloadOnShow="true" Width="500" Height="200" KeepInScreenBounds="true" Skin="Metro">
                    <ContentTemplate>
                        <telerik:RadFormDecorator ID="RadFormDecorator4" runat="server" DecoratedControls="All" DecorationZoneID="lockwindow" Skin="Metro" />

                        <div id="LetterEditReasondiv">
                            <table style="width: 100%; padding: 10px;">
                                <tr>
                                    <td>
                                        <asp:Label ID="ReasonLabel" runat="server" Text="Reason" /></td>
                                    <td>
                                        <telerik:RadTextBox ID="LetterEditReasonText" runat="server" Width="370" /></td>
                                </tr>
                                <tr>
                                    <td colspan="2" style="padding-top: 50px; text-align: right;"><%-- Change to number of columns --%>
                                        <div class="buttonsdiv" style="height: 10px; padding-top: 6px; vertical-align: central;">
                                            <telerik:RadButton ID="LetterEditReasonRadButton" runat="server" Text="Save" Skin="Metro"
                                                OnClick="SaveLLetterEditReasonRadButton_Click" />
                                            <telerik:RadButton ID="LetterEditReasonCloseRadButton" runat="server" Text="Cancel" Skin="Metro"
                                                OnClientClicked="CloseLetterEditReasonWindow" AutoPostBack="false" />
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </div>
                        <!-- Data goes here -->
                    </ContentTemplate>
                </telerik:RadWindow>
            </Windows>
        </telerik:RadWindowManager>
    </div>
    <asp:ObjectDataSource ID="CancelReasonsDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetCancellationReasons">
        <UpdateParameters>
            <asp:Parameter Name="CancelReasonId" DbType="Int32" DefaultValue="" />
            <asp:Parameter Name="Code" DbType="String" DefaultValue="" />
            <asp:Parameter Name="Detail" DbType="String" DefaultValue="False" />
            <asp:Parameter Name="CancelledByHospital" DbType="Boolean" DefaultValue="False" />
        </UpdateParameters>
        <InsertParameters>
            <asp:Parameter Name="CancelReasonId" DbType="Int32" DefaultValue="" />
            <asp:Parameter Name="Code" DbType="String" DefaultValue="" />
            <asp:Parameter Name="Detail" DbType="String" DefaultValue="False" />
            <asp:Parameter Name="CancelledByHospital" DbType="Boolean" DefaultValue="False" />
        </InsertParameters>
    </asp:ObjectDataSource>
    <%--------------  Schedule List    ------ --%>

        <asp:ObjectDataSource ID="GetScheduleListReasonsDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetScheduleListCancellationReasons">
        <UpdateParameters>
            <asp:Parameter Name="ListCancelReasonId" DbType="Int32" DefaultValue="" />
            <asp:Parameter Name="Code" DbType="String" DefaultValue="" />
            <asp:Parameter Name="Detail" DbType="String" DefaultValue="False" />
            <asp:Parameter Name="CancelledByHospital" DbType="Boolean" DefaultValue="False" />
        </UpdateParameters>
        <InsertParameters>
            <asp:Parameter Name="ListCancelReasonId" DbType="Int32" DefaultValue="" />
            <asp:Parameter Name="Code" DbType="String" DefaultValue="" />
            <asp:Parameter Name="Detail" DbType="String" DefaultValue="False" />
            <asp:Parameter Name="CancelledByHospital" DbType="Boolean" DefaultValue="False" />
        </InsertParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="DiaryLockReasonsObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetDiaryLockReasons" UpdateMethod="AddDiaryLockReason" InsertMethod="AddDiaryLockReason">
        <SelectParameters>
            <asp:Parameter Name="ignoreSuppressed" Type="Boolean" DefaultValue="False" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="LockReasonId" DbType="Int32" DefaultValue="" />
            <asp:Parameter Name="Reason" DbType="String" DefaultValue="" />
            <asp:Parameter Name="IsLockReason" DbType="Boolean" />
            <asp:Parameter Name="IsUnlockReason" DbType="Boolean" />
            <asp:Parameter Name="Suppressed" DbType="Boolean" />
        </UpdateParameters>
        <InsertParameters>
            <asp:Parameter Name="LockReasonId" DbType="Int32" DefaultValue="0" />
            <asp:Parameter Name="Reason" DbType="String" />
            <asp:Parameter Name="IsLockReason" DbType="Boolean" />
            <asp:Parameter Name="IsUnlockReason" DbType="Boolean" />
            <asp:Parameter Name="Suppressed" DbType="Boolean" />
        </InsertParameters>
    </asp:ObjectDataSource>

    <asp:ObjectDataSource ID="ListLockReasonsObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetListLockReasons" UpdateMethod="AddListLockReason" InsertMethod="AddListLockReason">
        <SelectParameters>
            <asp:Parameter Name="showSuppressed" Type="Boolean" DefaultValue="True" />
        </SelectParameters>
        <UpdateParameters>
            <asp:Parameter Name="LockReasonId" DbType="Int32" DefaultValue="" />
            <asp:Parameter Name="Reason" DbType="String" DefaultValue="" />
            <asp:Parameter Name="IsLockReason" DbType="Boolean" />
            <asp:Parameter Name="IsUnlockReason" DbType="Boolean" />
            <asp:Parameter Name="Suppressed" DbType="Boolean" />
        </UpdateParameters>
        <InsertParameters>
            <asp:Parameter Name="LockReasonId" DbType="Int32" DefaultValue="0" />
            <asp:Parameter Name="Reason" DbType="String" />
            <asp:Parameter Name="IsLockReason" DbType="Boolean" />
            <asp:Parameter Name="IsUnlockReason" DbType="Boolean" />
            <asp:Parameter Name="Suppressed" DbType="Boolean" />
        </InsertParameters>
    </asp:ObjectDataSource>
    <asp:ObjectDataSource ID="LetterEditReasonsDataSource" runat="server" TypeName="UnisoftERS.LetterGeneration" SelectMethod="GetLetterEditReasons"></asp:ObjectDataSource>
</asp:Content>
