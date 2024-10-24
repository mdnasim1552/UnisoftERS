<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_FieldLabels" CodeBehind="FieldLabels.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        .lefthide {
            float: left;
            display: none;
            color: red;
        }

        .suppressChkBox {
            float: right;
            direction: rtl;
        }

        .checkbox input[type="checkbox"] {
            width: 17px;
            height: 22px;
            margin-left: 0px !important;
        }
    </style>

    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            $(window).on('load', function () {

            });



            $(document).ready(function () {
                var tst = {
                    items: [
                        { "Control": "txtName", "FieldName": "Name" },
                        { "Control": "txtSurname", "FieldName": "Surname" },
                        { "Control": "txtDOB", "FieldName": "DOB" }
                    ]
                };

                var jVal = JSON.stringify(tst);

                $('#<%=EditRequiredFieldCheckBox.ClientID%>').on('change', function () {
                    toggleFieldName();
                });
            });

            function openAddItemWindow(itemId, LabelName, LabelID, Override, Plural, Description, TextColour, sProcedureType, Required, FieldName, Suppressed, EditableFields, EditingType) {
                var oWnd = $find("<%= AddNewItemRadWindow.ClientID%>");
                if (itemId > 0) {
                    document.getElementById("tdItemTitle").innerHTML = '<b>' + LabelName + '(' + LabelID + ')</b>';
                    $find('<% =AddNewItemSaveRadButton.ClientID%>').set_text("Update");
                    oWnd.set_title('Edit ' + EditingType);
                    if (Required == "True") {
                        $("#<%=EditRequiredFieldCheckBox.ClientID%>").prop("checked", true);
                    }
                    else {
                        $("#<%=EditRequiredFieldCheckBox.ClientID%>").prop("checked", false);
                    }
                    if (Suppressed == "True") {
                        $("#<%=EditRequiredFieldCheckBox.ClientID%>").attr("disabled", true);
                    }
                    else {
                        $("#<%=EditRequiredFieldCheckBox.ClientID%>").attr("disabled", false);
                    }
                    if (EditableFields == "False") {
                        $("#<%=EditOverrideRadTextBox.ClientID%>").attr("disabled", true);
                        $("#<%=EditPluralTextBox.ClientID%>").attr("disabled", true);
                    }
                    else {
                        $("#<%=EditOverrideRadTextBox.ClientID%>").removeAttr('title');
                        $("#<%=EditPluralTextBox.ClientID%>").removeAttr('title');
                    }

                    $find("<%=EditFieldNameTextBox.ClientID%>").set_value(FieldName.replace("~", "'"));
                    $find("<%=EditOverrideRadTextBox.ClientID%>").set_value(Override.replace("~", "'"));
                    $find("<%=EditPluralTextBox.ClientID%>").set_value(Plural.replace("~", "'"));
                    $find("<%=EditHintTextBox.ClientID%>").set_value(Description.replace("~", "'"));
                    $find("<%=RadColourPicker.ClientID%>").set_selectedColor(TextColour.substring(0, 7));
                    var procCtrl = $find("<%=ProcedureComboBox.ClientID()%>");
                    clearChecked(procCtrl);
                    if (sProcedureType != null && sProcedureType != '') {
                        var pArray = sProcedureType.split(",");
                        $.each(pArray, function (i) {
                            var tm = procCtrl.findItemByValue(pArray[i]);
                            if (tm != null) { tm.set_checked(true); }
                        });
                    }


                    $("#hiddenItemId").val(itemId);
                } else {
                    document.getElementById("tdItemTitle").innerHTML = '<b>Add new item</b>';
                    $find('<% =AddNewItemSaveRadButton.ClientID%>').set_text("Save");
                    oWnd.set_title('New Item');
                    $find("<%=EditOverrideRadTextBox.ClientID%>").set_value("");
                }

                toggleFieldName();

                oWnd.show();
                return false;
            }
            function clearChecked(procCtrl) {
                var items = procCtrl.get_checkedItems();
                var i = 0;
                while (i < items.length) {
                    items[i].uncheck();
                    i++;
                }
            }
            function closeAddItemWindow() {
                var oWnd = $find("<%= AddNewItemRadWindow.ClientID%>");
                if (oWnd != null)
                    oWnd.close();
                return false;
            }

            function refreshGrid(arg) {
                if (!arg) {
                    $find("<%= RadAjaxManager1.ClientID %>").ajaxRequest("Rebind");
                }
                else {
                    $find("<%= RadAjaxManager1.ClientID %>").ajaxRequest("RebindAndNavigate");
                }
            }

            function Show() {
                if (confirm("Are you sure you want to suppress this item?")) {
                    return true;
                }
                else {
                    return false;
                }
            }

            function showSuppressedItems(sender, args) {
                document.getElementById('hiddenShowSuppressedItems').value = args.get_checked();
                var masterTable = $find("<%= ListsRadGrid.ClientID%>").get_masterTableView();
                masterTable.rebind();
            }


            function toggleFieldName() {
                $("#FieldNameValidationDiv").hide();

                if ($('#<%=EditRequiredFieldCheckBox.ClientID%>').prop("checked")) {
                    $('#FieldNameDiv').show();
                }
                else {
                    $('#FieldNameDiv').hide();
                    var editFieldTextBox = $find('<%=EditFieldNameTextBox.ClientID%>');
                    if (editFieldTextBox != null)
                        editFieldTextBox.set_value("");
                }
            }

            function validateForm(sender, args) {
                var valid = true;
                if ($('#<%=EditRequiredFieldCheckBox.ClientID%>').prop("checked") && $('#<%=EditFieldNameTextBox.ClientID%>').val() == "") {
                    valid = false;
                }

                if (valid == true) { return; }
                else {
                    $("#FieldNameValidationDiv").show();
                    args.set_cancel(true);
                }
            }


        </script>
    </telerik:RadScriptBlock>
</head>

<body>
    <script type="text/javascript">
    </script>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hiddenItemId" runat="server" />
        <asp:HiddenField ID="hiddenShowSuppressedItems" runat="server" Value="0" />
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />

        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest">
            <AjaxSettings>
                <telerik:AjaxSetting AjaxControlID="RadAjaxManager1">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ListsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="ListsRadGrid">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ListsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="FilterByComboBox">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="ListsRadGrid" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>

        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro">
        </telerik:RadAjaxLoadingPanel>

        <div class="optionsHeading">Field Labels</div>

        <telerik:RadFormDecorator ID="ListItemRadFormDecorator" runat="server" DecoratedControls="All"
            DecorationZoneID="FormDiv" Skin="Web20" />

        <asp:ObjectDataSource ID="FieldLabelsObjectDataSource" runat="server" SelectMethod="GetFieldLabels" TypeName="UnisoftERS.Options">
            <SelectParameters>
                <asp:ControlParameter Name="PageID" DbType="String" ControlID="FilterByComboBox" PropertyName="SelectedValue" ConvertEmptyStringToNull="true" DefaultValue="0" />
            </SelectParameters>
        </asp:ObjectDataSource>

        <div id="FormDiv" runat="server">
            <div style="margin-top: 5px; margin-left: 10px;" class="optionsBodyText">
                <div style="margin-top: 15px;">
                    <table>
                        <tr>
                            <td>Select page :
                                <telerik:RadComboBox ID="FilterByComboBox" runat="server" Skin="Windows7" Width="270px" AutoPostBack="true" Height="300" CssClass="filterDDL" />
                            </td>
                        </tr>
                        <tr>
                            <td style="padding-top: 20px;">
                                <div class="optionsSubHeading" style="padding-bottom: 5px; float:left;">Labels</div>
                                <telerik:RadGrid ID="ListsRadGrid1" runat="server" AutoGenerateColumns="false" AllowMultiRowSelection="false" Visible="false"
                                    DataSourceID="FieldLabelsObjectDataSource" PageSize="10" AllowPaging="true" AllowSorting="true"
                                    CellSpacing="0" GridLines="None" Skin="Metro" Width="700px">
                                    <HeaderStyle Font-Bold="true" Height="25" />
                                    <MasterTableView ShowHeadersWhenNoRecords="true" DataKeyNames="FieldLabelID" ClientDataKeyNames="FieldLabelID">

                                        <Columns>
                                            <telerik:GridBoundColumn DataField="LabelName" UniqueName="LabelName" HeaderText="Field Name" SortExpression="FieldName" HeaderStyle-Width="170px" />
                                        </Columns>
                                        <NoRecordsTemplate>
                                            <div style="margin-left: 5px;">No records found</div>
                                        </NoRecordsTemplate>

                                    </MasterTableView>
                                    <ItemStyle Height="3" />
                                    <AlternatingItemStyle Height="3" />
                                    <PagerStyle Mode="NumericPages"></PagerStyle>
                                </telerik:RadGrid>
                            </td>
                        </tr>
                    </table>
                </div>


                <telerik:RadGrid ID="ListsRadGrid" GridLines="None" runat="server" AllowAutomaticDeletes="False" Skin="Metro"
                    AllowAutomaticInserts="False" PageSize="200" AllowAutomaticUpdates="True" AllowPaging="True"
                    AutoGenerateColumns="False" DataSourceID="FieldLabelsObjectDataSource" Width="850px" AllowFilteringByColumn="True">
                    <GroupingSettings CaseSensitive="false" />
                    <MasterTableView DataKeyNames="FieldLabelID"
                        DataSourceID="FieldLabelsObjectDataSource" HorizontalAlign="NotSet" AutoGenerateColumns="False" AllowFilteringByColumn="True">
                        <CommandItemSettings ShowAddNewRecordButton="false" />
                         <BatchEditingSettings EditType="Row" />
                        <Columns>
                            <telerik:GridTemplateColumn UniqueName="TemplateColumn" HeaderStyle-Width="40px" AllowFiltering="false">
                                <ItemTemplate>
                                    <asp:LinkButton ID="EditLinkButton" runat="server" Text="Edit" ToolTip="Edit this item" Font-Italic="true"></asp:LinkButton>
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridTemplateColumn HeaderText="Colour" HeaderStyle-Width="50px" UniqueName="Colour" ItemStyle-HorizontalAlign="Center" AllowFiltering="false">
                                <ItemTemplate>
                                    <asp:Label ID="ColourLabel" runat="server" Width="30" Height="12"></asp:Label>
                                    <%--<telerik:RadColorPicker ID="RadColourPicker" runat="server" ShowIcon="true" Enabled="false" >  
                            </telerik:RadColorPicker> --%>
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                            <telerik:GridBoundColumn DataField="LabelName"  HeaderStyle-Width="150px" HeaderText="Control Name" SortExpression="LabelName" ReadOnly="true" UniqueName="LabelName"
                                AutoPostBackOnFilter="true" CurrentFilterFunction="Contains" ShowFilterIcon="false">
                                <ColumnValidationSettings EnableRequiredFieldValidation="true">
                                    <RequiredFieldValidator ForeColor="Red" Text="*This field is required" Display="Dynamic" />
                                </ColumnValidationSettings>
                            </telerik:GridBoundColumn>
                            <telerik:GridBoundColumn DataField="Override" HeaderStyle-Width="150px" HeaderText="Override" SortExpression="Override" UniqueName="Override" AllowFiltering="false" />
                            <telerik:GridBoundColumn DataField="Plural" HeaderStyle-Width="150px" HeaderText="Plural" SortExpression="Plural" UniqueName="Plural" Visible="false" AllowFiltering="false" />
                            <telerik:GridBoundColumn DataField="Hint" HeaderStyle-Width="190px" HeaderText="Description" SortExpression="Hint" UniqueName="Hint" AllowFiltering="false" />
                            <telerik:GridTemplateColumn UniqueName="RequiredColumn" DataField="Required" HeaderText="Required" SortExpression="Required" HeaderStyle-Width="75px" AllowFiltering="false" ItemStyle-HorizontalAlign="Center">
                                <ItemTemplate>
                                    <asp:CheckBox ID="RequiredCheckBox" runat="server" AutoPostBack="true"
                                        Checked='<%# Bind("Required") %>' Enabled="false" />
                                </ItemTemplate>
                            </telerik:GridTemplateColumn>
                            <%--<telerik:GridBoundColumn DataField="Colour"  HeaderText="Colour" SortExpression="Colour" UniqueName="Colour" />--%>




                            <%--                    <telerik:GridButtonColumn ConfirmText="Delete this product?" ConfirmDialogType="RadWindow"
                        ConfirmTitle="Delete" HeaderText="Delete" HeaderStyle-Width="50px" ButtonType="ImageButton"
                        CommandName="Delete" Text="Delete" UniqueName="DeleteColumn">
                    </telerik:GridButtonColumn>--%>
                        </Columns>
                    </MasterTableView>
                    <PagerStyle Mode="NextPrev" />
                    <ClientSettings AllowKeyboardNavigation="true">
                        <Scrolling AllowScroll="True" UseStaticHeaders="true" ScrollHeight="450px" />
                    </ClientSettings>
                </telerik:RadGrid>

                <telerik:RadWindowManager ID="RadWindowManager1" runat="server">
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
                                                <td>Override :
                                                </td>
                                                <td colspan="3">
                                                    <telerik:RadTextBox ID="EditOverrideRadTextBox" runat="Server" Width="280px" ToolTip="This field is uneditable" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Plural :
                                                </td>
                                                <td colspan="3">
                                                    <telerik:RadTextBox ID="EditPluralTextBox" runat="Server" Width="280px" ToolTip="This field is uneditable" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Description :
                                                </td>
                                                <td colspan="3">
                                                    <telerik:RadTextBox ID="EditHintTextBox" runat="Server" Width="280px" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>Procedure(s) :
                                                </td>
                                                <td colspan="3">
                                                    <telerik:RadComboBox ID="ProcedureComboBox" DataSourceID="ProcedureObjectDataSource" runat="server" CheckBoxes="true" ZIndex="9501" EnableCheckAllItemsCheckBox="true" Width="280px" Skin="Windows7" DataTextField="ProcedureType" DataValueField="ProcedureTypeId" />
                                                    <asp:ObjectDataSource ID="ProcedureObjectDataSource" runat="server" SelectMethod="GetProcedures" TypeName="UnisoftERS.Options" />

                                                </td>
                                            </tr>
                                            <tr>
                                                <%-- <td>
                                                    Control type :
                                                </td>
                                                <td>
                                                    <telerik:RadDropDownList ID="ControlTypeDownList" runat="server" Skin="Windows7" ZIndex="9500" Width="100px" Enabled="true" >
                                                        <Items>
                                                            <telerik:DropDownListItem/>
                                                            <telerik:DropDownListItem Text="Label" Value="Label"></telerik:DropDownListItem>
                                                            <telerik:DropDownListItem Text="CheckBox" Value="CheckBox"></telerik:DropDownListItem>
                                                            <telerik:DropDownListItem Text="Radio" Value="Radio"></telerik:DropDownListItem>
                                                            <telerik:DropDownListItem Text="Button" Value="Button"></telerik:DropDownListItem>
                                                        </Items>
                                                    </telerik:RadDropDownList>
                                                </td>--%>
                                                <td>Colour :
                                                </td>
                                                <td>
                                                    <telerik:RadColorPicker ID="RadColourPicker" runat="server" ShowIcon="true" PaletteModes="All" />
                                                </td>
                                            </tr>
                                            <tr>
                                                <td valign="middle">Required:</td>
                                                <td>
                                                    <asp:CheckBox ID="EditRequiredFieldCheckBox" CssClass="checkbox" SkinID="Metro" runat="server" Style="float: left;" onclick="toggleFieldName" />
                                                    <div id="FieldNameDiv" style="padding: 5px 0 0 11px; float: left;">
                                                        Field Name:&nbsp;
                                                    <telerik:RadTextBox ID="EditFieldNameTextBox" runat="Server" Width="180px" /><br />
                                                        <span class="lefthide" id="FieldNameValidationDiv" style="position: absolute; left: 28px; padding-top: 4px;">*A field name must be specified when required is ticked</span>
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <div id="buttonsdiv" style="height: 10px; padding-top: 16px; vertical-align: central;">
                                            <telerik:RadButton ID="AddNewItemSaveRadButton" runat="server" Text="Save" Skin="Web20" OnClientClicked="validateForm" />
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
    </form>
</body>
</html>
