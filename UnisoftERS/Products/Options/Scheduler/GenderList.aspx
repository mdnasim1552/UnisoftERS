<%@ Page Language="vb" MasterPageFile="~/Templates/Scheduler.master" AutoEventWireup="false" CodeBehind="GenderList.aspx.vb" Inherits="UnisoftERS.GenderList" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContentPlaceHolder" runat="Server">
    <link href="../../../Styles/Site.css" rel="stylesheet" />

    <script src="../../../Scripts/jquery-3.6.3.min.js"></script>
    <title></title>
    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <style>
            .RadAjaxPanel {
                display: inline !important;
            }
        </style>
        <script type="text/javascript">
            var docURL = document.URL;

            $(window).on('load', function () {

            });

            $(document).ready(function () {
                Sys.Application.add_load(function () {
                    bindPageEvents();
                });
                document.getElementById("<%= GenderListRadGrid.ClientID%>").style.height = (document.documentElement.clientHeight - 200) + 'px';
                $(window).resize(function() {
                    document.getElementById("<%= GenderListRadGrid.ClientID%>").style.height = (document.documentElement.clientHeight - 200) + 'px';
                });
            });

            function bindPageEvents() {
                $('.gender-checkbox').on('change', function () {
                    var gvID = $find('<%=GenderListRadGrid.ClientID %>');
                    var masterTableView = gvID.get_masterTableView();

                    var rowIndex = $(this).closest('tr').find('.hidden-label').text();
                    var timePeriod = $(this).attr("data-timeslot");

                    var gvDataItems = masterTableView.get_dataItems()[parseInt(rowIndex)];
                    var ListDate = gvDataItems.getDataKeyValue("ListDate");
                    var AMDiaryID = gvDataItems.getDataKeyValue("AMDiaryID");
                    var PMDiaryID = gvDataItems.getDataKeyValue("PMDiaryID");
                    var EVDiaryID = gvDataItems.getDataKeyValue("EVDiaryID");

                    var ListMale;
                    var ListFemale;

                    $(this).find('input').each(function (index, item) {
                        if ($(item).val().toLowerCase() == "f") {
                            ListFemale = $(item).is(":checked");
                        }
                        if ($(item).val().toLowerCase() == "m") {
                            ListMale = $(item).is(":checked");
                        }
                    });

                    var obj = {};
                    obj.listDate = ListDate;

                    if (timePeriod.toLowerCase() == "am" && AMDiaryID != "") {
                        obj.diaryID = parseInt(AMDiaryID);
                    }

                    if (timePeriod.toLowerCase() == "pm" && PMDiaryID != "") {
                        obj.diaryID = parseInt(PMDiaryID);
                    }

                    if (timePeriod.toLowerCase() == "ev" && EVDiaryID != "") {
                        obj.diaryID = parseInt(EVDiaryID);
                    }

                    obj.male = ListMale;
                    obj.female = ListFemale;

                    $.ajax({
                        type: "POST",
                        url: docURL.slice(0, docURL.indexOf("/Products/")) + "/Products/Scheduler/Scheduler.aspx/UpdateGenderList",
                        data: JSON.stringify(obj),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (r) {
                            if (r.d != null) {
                                if (r.d === false) {
                                    alert('failed');
                                }
                            }
                        }
                    });
                });
            }
        </script>
    </telerik:RadScriptBlock>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="BodyContentPlaceHolder" runat="Server">
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Metro" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
        </telerik:RadAjaxLoadingPanel>
        <%--<telerik:RadAjaxManager runat="server" ID="RadAjaxManager1">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="SelectRoomButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="GenderListRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="BackMonthRadButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="GenderListRadGrid" LoadingPanelID="RadAjaxLoadingPanel1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>--%>

        <div id="FormDiv" style="padding:10px;">
            <div class="optionsHeading">
                <asp:Label ID="HeadingLabel" runat="server" Text="Set Gender for lists"></asp:Label>
            </div>

            <div class="optionsBodyText">
                <table style="width: 100%;">
                    <tr>
                        <td style="width: 525px;">
                            <table cellspacing="0" style="width: 100%;">
                                <tr>
                                    <td>
                                        <div>
                                            Hospital:&nbsp;<telerik:RadDropDownList ID="HospitalDropDownList" runat="server" Width="200" DataTextField="HospitalName" AutoPostBack="true" DataValueField="OperatingHospitalID" DataSourceID="HospitalObjectDataSource" />
                                        </div>
                                    </td>
                                    <td>
                                        <div>
                                            Room(s):&nbsp;<telerik:RadComboBox ID="RoomsDropdown" runat="server" Width="200" DataSourceID="HospitalRoomsDataSource" DataValueField="RoomId" DataTextField="RoomName" AutoPostBack="false" OnPreRender="RoomsDropdown_PreRender" />
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td valign="top">
                            <telerik:RadButton ID="SelectRoomButton" runat="server" Text="Change Rooms" OnClick="SelectRoomButton_Click" />
                        </td>
                    </tr>
                </table>
            </div>
            <div style="width: 950px;">
                <div id="MonthFilterDiv" style="text-align: center; margin-top: 10px; margin-bottom: 10px;">
                    <asp:HiddenField ID="SelectedMonthHiddenField" runat="server" />
                    <asp:HiddenField ID="SelectedYearHiddenField" runat="server" />
                    <telerik:RadButton ID="BackMonthRadButton" runat="server" Text="<<" OnClick="BackMonthButton_Click" />
                    <%--<asp:Button ID="BackMonthButton" runat="server" Text="<" OnClick="BackMonthButton_Click" />&nbsp;--%>
                    <asp:Label ID="MonthLabel" runat="server" Text="Month" />&nbsp;
                    <asp:Button ID="ForwardMonthButton" runat="server" Text=">>" OnClick="ForwardMonthButton_Click" />
                </div>
                <telerik:RadGrid ID="GenderListRadGrid" Height="525" Width="850px" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false" AllowSorting="true" OnItemDataBound="GenderListRadGrid_ItemDataBound" ItemStyle-Height="5px">
                    <HeaderStyle Font-Bold="true" />
                    <MasterTableView ShowHeadersWhenNoRecords="true" EnableNoRecordsTemplate="true" ClientDataKeyNames="ListDate,AMDiaryID,AMListGender,PMDiaryID,PMListGender,EVDiaryID,EVListGender">
                        <Columns>
                            <telerik:GridBoundColumn DataField="RowDate" HeaderText="" SortExpression="RowDate" HeaderStyle-Width="30px" ItemStyle-CssClass="day-column" />
                            <telerik:GridTemplateColumn ItemStyle-BackColor="Black" HeaderStyle-Width="1px" />
                            <telerik:GridTemplateColumn UniqueName="AMColumn" HeaderText="Morning" HeaderStyle-Width="45px">
                                <HeaderStyle HorizontalAlign="Right"/>
                                <ItemTemplate>
                                    <asp:Label ID="RowIndexHiddenLabel" runat="server" Text='<%#Eval("RowIndex") %>' CssClass="hidden-label" Style="display: none;" />
                                    <asp:Label ID="AMListNameLabel" runat="server" Text='<%#Eval("AMListName") %>' style="height:10px"/>
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridTemplateColumn UniqueName="AMColumnMF" HeaderText="" HeaderStyle-Width="35px">
                                <ItemTemplate>
                                    <asp:CheckBoxList ID="AMCheckboxList" runat="server" Visible="false" RepeatDirection="Horizontal" CssClass="gender-checkbox" data-timeslot="am" style="height:10px">
                                        <asp:ListItem>M</asp:ListItem>
                                        <asp:ListItem>F</asp:ListItem>
                                    </asp:CheckBoxList>
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridTemplateColumn ItemStyle-BackColor="Black" HeaderStyle-Width="1px" />

                            <telerik:GridTemplateColumn UniqueName="PMColumn" HeaderText="Afternoon" HeaderStyle-Width="45px">
                                <HeaderStyle HorizontalAlign="Right"/>
                                <ItemTemplate>
                                    <asp:Label ID="PMListNameLabel" runat="server" Text='<%#Eval("PMListName") %>'  style="height:10px"/>
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridTemplateColumn UniqueName="PMColumnMF" HeaderText="" HeaderStyle-Width="35px">
                                <ItemTemplate>
                                    <asp:CheckBoxList ID="PMCheckboxList" runat="server" Visible="false" RepeatDirection="Horizontal" CssClass="gender-checkbox" data-timeslot="pm" style="height:10px">
                                        <asp:ListItem>M</asp:ListItem>
                                        <asp:ListItem>F</asp:ListItem>
                                    </asp:CheckBoxList>
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                            
                            <telerik:GridTemplateColumn ItemStyle-BackColor="Black" HeaderStyle-Width="1px" />
                            <telerik:GridTemplateColumn UniqueName="EVColumn" HeaderText="Evening" HeaderStyle-Width="45px">
                                <HeaderStyle HorizontalAlign="Right"/>
                                <ItemTemplate>
                                    <asp:Label ID="EVListNameLabel" runat="server" Text='<%#Eval("EVListName") %>' style="height:10px" />
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridTemplateColumn UniqueName="EVColumnMF" HeaderText="" HeaderStyle-Width="35px">
                                <ItemTemplate>
                                    <asp:CheckBoxList ID="EVCheckboxList" runat="server" Visible="false" RepeatDirection="Horizontal" CssClass="gender-checkbox" data-timeslot="ev" style="height:10px">
                                        <asp:ListItem>M</asp:ListItem>
                                        <asp:ListItem>F</asp:ListItem>
                                    </asp:CheckBoxList>
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                        </Columns>
                    </MasterTableView>
                    <ClientSettings>
                        <Scrolling AllowScroll="true" UseStaticHeaders="true"/>
                    </ClientSettings>
                </telerik:RadGrid>
            </div>
        </div>

        <asp:ObjectDataSource ID="HospitalObjectDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetSchedulerHospitals" />
        <asp:ObjectDataSource ID="HospitalRoomsDataSource" runat="server" TypeName="UnisoftERS.DataAccess_Sch" SelectMethod="GetHospitalRooms">
            <SelectParameters>
                <asp:ControlParameter ControlID="HospitalDropDownList" DbType="Int32" Name="HospitalID" PropertyName="SelectedValue" />
            </SelectParameters>
        </asp:ObjectDataSource>
</asp:Content>