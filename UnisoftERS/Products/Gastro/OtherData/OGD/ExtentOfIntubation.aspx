<%@ Page Title="" Language="VB" MasterPageFile="~/Templates/ProcedureMaster.Master" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_OtherData_OGD_ExtentOfIntubation" Codebehind="ExtentOfIntubation.aspx.vb" %>

<%@ MasterType VirtualPath="~/Templates/ProcedureMaster.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="pHeadContentPlaceHolder" runat="Server">
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/Global.js"></script>
    <style type="text/css">
        .rbl label {margin-right: 40px;}
    </style>

    <script type="text/javascript">
        var isSaved = false;

        //$(window).on(BeforeUnloadEvent)(function () { checkForValidPage("Save") });
        //window.addEventListener('beforeunload', (event) => {
        window.onbeforeunload = function (event) {
            document.getElementById("<%= SaveOnly.ClientID %>").click();
//            if (!isSaved) {
//                debugger;
//                currentLoadingPanel = $find("<%= RadAjaxLoadingPanel1.ClientID %>");
//                currentUpdatedControl = "<%= ControlsRadPane.ClientID %>";
//                currentLoadingPanel.hide(currentUpdatedControl);
//                currentLoadingPanel.set_modal(false);

//                event.preventDefault();
//                event.returnValue = 'Are you sure you want to leave?';
//            }
        };

        $(window).on('load', function () {
            var tabTrainee = $find("<%= radProcedureExtent.ClientID%>").findTabByValue(0);
            if (tabTrainee) {
                ToggleControlsTrainee();
                ToggleValidatorTrainee();
            }
            ToggleControlsTrainer();
            ToggleValidatorTrainer();
            ToggleJManoeuvre();
        });

        function ToggleJManoeuvre() {
            var procTypeId = $('#<%=ProcedureTypeIdHiddenField.ClientID %>').val();

            //22 Oct 2021 MH changed as below. TFS Item : 1536 ENT J Manouver
            if (procTypeId == '6' || procTypeId == '8') {   //EUS (OGD)
                

                ValidatorEnable(document.getElementById("<%= JmanoeuvreRequiredFieldValidator.ClientID%>"), false);
                ValidatorEnable(document.getElementById("<%= TrainerJmanoeuvreRequiredFieldValidator.ClientID%>"), false);

                $('#JMan2').hide();
                $('#JMan').hide();
            }
        }

        function ToggleControlsTrainee() {
            <%--'## If trainEE tab not visible then exit function --%>
            if (!$find("<%= radProcedureExtent.ClientID%>").findTabByValue(0)) {
                return;
            }

            if ($("#<%= SuccessfulRadioButton.ClientID%>").is(':checked')) {
                var combo = $find('<%= ExtentComboBox.ClientID%>');
                combo.enable();
                combo.showDropDown();
                ValidatorEnable(document.getElementById("<%= ExtentRequiredFieldValidator.ClientID%>"), true);
                ValidatorEnable(document.getElementById("<%= FailedOtherRequiredFieldValidator.ClientID%>"), false);

                $("form input:radio:checked[name*='TraineeFailedOptions']").removeAttr("checked");
                $("form input:radio[name*='TraineeFailedOptions']").attr('disabled', true);
                $("#<%= FailedOtherTextBox.ClientID%>").val('');
                $("#<%= FailedOtherTextBox.ClientID%>").attr('disabled', true);
            }
            else if ($("#<%= FailedRadioButton.ClientID%>").is(':checked')) {
                $("form input:radio[name*='TraineeFailedOptions']").attr('disabled', false);
                $("#<%= FailedOtherTextBox.ClientID%>").attr('disabled', false);

                <%--$('#<%= ExtentComboBox.ClientID%> input:text').val('');--%>
                $find('<%= ExtentComboBox.ClientID%>').clearSelection();
                $find('<%= ExtentComboBox.ClientID%>').disable();
                ValidatorEnable(document.getElementById("<%= ExtentRequiredFieldValidator.ClientID%>"), false);
                ValidatorEnable(document.getElementById("<%= FailedOtherRequiredFieldValidator.ClientID%>"), true);
            }
            else {
                $("form input:radio:checked[name*='TraineeFailedOptions']").removeAttr("checked");
                $("#<%= FailedOtherTextBox.ClientID%>").val('');
                $('#<%= ExtentComboBox.ClientID%> input:text').val('');

                $("form input:radio[name*='TraineeFailedOptions']").attr('disabled', true);
                $("#<%= FailedOtherTextBox.ClientID%>").attr('disabled', true);
                $find('<%= ExtentComboBox.ClientID%>').disable();

                ValidatorEnable(document.getElementById("<%= ExtentRequiredFieldValidator.ClientID%>"), false);
            }

          <%--  if (($("#<%= JmanoeuvreNotDoneRadioButton.ClientID%>").is(':checked')) || ($("#<%= JmanoeuvreDoneRadioButton.ClientID%>").is(':checked'))) {
                ValidatorEnable(document.getElementById("<%= JmanoeuvreRequiredFieldValidator.ClientID%>"), false);
            } else {
                ValidatorEnable(document.getElementById("<%= JmanoeuvreRequiredFieldValidator.ClientID%>"), true);
            }--%>
        }

        function ToggleControlsTrainer() {
            if ($("#<%= TrainerSuccessfulRadioButton.ClientID%>").is(':checked')) {

               var combo = $find('<%= TrainerExtentComboBox.ClientID%>');
                combo.enable();
                //combo.showDropDown();

                $("form input:radio:checked[name*='TrainerFailedOptions']").removeAttr("checked");
                $("form input:radio[name*='TrainerFailedOptions']").attr('disabled', true);
                $("#<%= TrainerFailedOtherTextBox.ClientID%>").val('');
                $("#<%= TrainerFailedOtherTextBox.ClientID%>").attr('disabled', true);
                ValidatorEnable(document.getElementById("<%= TrainerFailedOtherRequiredFieldValidator.ClientID%>"), false);
            }
            else if ($("#<%= TrainerFailedRadioButton.ClientID%>").is(':checked')) {
                $("form input:radio[name*='TrainerFailedOptions']").attr('disabled', false);
                $("#<%= TrainerFailedOtherTextBox.ClientID%>").attr('disabled', false);

                $find('<%= TrainerExtentComboBox.ClientID%>').clearSelection();
                $find('<%= TrainerExtentComboBox.ClientID%>').disable();
                ValidatorEnable(document.getElementById("<%= TrainerExtentRequiredFieldValidator.ClientID%>"), false);
            }
            else {
                $("form input:radio:checked[name*='TrainerFailedOptions']").removeAttr("checked");
                $("#<%= TrainerFailedOtherTextBox.ClientID%>").val('');
                $('#<%= TrainerExtentComboBox.ClientID%> input:text').val('');

                $("form input:radio[name*='TrainerFailedOptions']").attr('disabled', true);
                $("#<%= TrainerFailedOtherTextBox.ClientID%>").attr('disabled', true);
                $find('<%= TrainerExtentComboBox.ClientID%>').disable();
            }
<%--            var trainerFailedOptions = $("form input:radio:checked[name*='TrainerFailedOptions']").is(':checked');
            alert(trainerFailedOptions);
            if ($("#<%= TrainerFailedOtherRadioButton.ClientID%>").is(':checked')   &&  (!$("form input:radio:checked[name*='TrainerFailedOptions']").is(':checked'))) {
                ValidatorEnable(document.getElementById("<%= TrainerFailedOtherRequiredFieldValidator.ClientID%>"), true);
            } else {
                ValidatorEnable(document.getElementById("<%= TrainerFailedOtherRequiredFieldValidator.ClientID%>"), false);
            }--%>

       }

        function SelectParent(type) {
            if (type == 'success') {
                $("#<%= SuccessfulRadioButton.ClientID%>").prop('checked', true);
                }
                else if (type == 'fail') {
                    $("#<%= FailedRadioButton.ClientID%>").prop('checked', true);
                }
            ToggleControlsTrainee();
        }

        function ToggleValidatorTrainee() {
            if ($("#<%= FailedOtherRadioButton.ClientID%>").is(':checked')) {
                    ValidatorEnable(document.getElementById("<%= FailedOtherRequiredFieldValidator.ClientID%>"), true);
                    $("#<%= FailedOtherTextBox.ClientID%>").attr('disabled', false);
                }
                else {
                    $("#<%= FailedOtherTextBox.ClientID%>").val('');
                    $("#<%= FailedOtherTextBox.ClientID%>").attr('disabled', true);
                    ValidatorEnable(document.getElementById("<%= FailedOtherRequiredFieldValidator.ClientID%>"), false);
            }
        }

        function ToggleValidatorTrainer() {
            if ($("#<%= TrainerFailedOtherRadioButton.ClientID%>").is(':checked')) {
                $("#<%= TrainerFailedOtherTextBox.ClientID%>").attr('disabled', false);
            }
            else {
                $("#<%= TrainerFailedOtherTextBox.ClientID%>").val('');
                $("#<%= TrainerFailedOtherTextBox.ClientID%>").attr('disabled', true);
            }
        }

        function checkForValidPage(button, args) {
            <%--'## If either J manoeuvre trainee or trainer checked, then disable validator --%>
            if (($('#<%=JmanoeuvreRadioButtonList.ClientID%> input[type=radio]:checked').val() > 0) ||
                ($('#<%=TrainerJmanoeuvreRadioButtonList.ClientID%> input[type=radio]:checked').val() > 0))
            {
                ValidatorEnable(document.getElementById("<%= JmanoeuvreRequiredFieldValidator.ClientID%>"), false);
                ValidatorEnable(document.getElementById("<%= TrainerJmanoeuvreRequiredFieldValidator.ClientID%>"), false);
            }
            

            var trainerFailedOptions = $("form input:radio:checked[name*='TrainerFailedOptions']").is(':checked');
            var trainerFailedComplete = $("#<%= TrainerFailedRadioButton.ClientID%>").is(':checked');
            
            if (trainerFailedComplete && !trainerFailedOptions) {
                ValidatorEnable(document.getElementById("<%= TrainerFailedOtherRequiredFieldValidator.ClientID%>"), true);
                args.set_cancel(true);
            } else {
                ValidatorEnable(document.getElementById("<%= TrainerFailedOtherRequiredFieldValidator.ClientID%>"), false);
            }

            var trainerSuccessful = $("#<%= TrainerSuccessfulRadioButton.ClientID%>").is(':checked');
            var trainerExtent = $find('<%= TrainerExtentComboBox.ClientID%>').get_value();

            if (trainerSuccessful && trainerExtent == '') {
                ValidatorEnable(document.getElementById("<%= TrainerExtentRequiredFieldValidator.ClientID%>"), true);
                args.set_cancel(true);
            } else {
                ValidatorEnable(document.getElementById("<%= TrainerExtentRequiredFieldValidator.ClientID%>"), false);
            }
            
            
            var valid = Page_ClientValidate("Save");
            if (!valid) {
                $find("<%=SaveRadNotification.ClientID%>").show();
            }

        }
    </script>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="pBodyContentPlaceHolder" runat="Server">
    <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ContentDiv" Skin="Web20" />
    <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="800px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
        <telerik:RadPane ID="ControlsRadPane" runat="server" Height="505px" Scrolling="Y">
            <div id="ContentDiv">
                <div class="otherDataHeading">
                    <b>Extent of Intubation</b></div>
                <div id="TabStripContainer" style="margin-left: 20px;margin-top: 20px;"">
                    <asp:HiddenField runat="server" ID="ProcedureTypeIdHiddenField"/>
                    <telerik:RadTabStrip ID="radProcedureExtent" runat="server" MultiPageID="radMultiExtentPageViews" Skin="Metro" Width="680px" RenderMode="Lightweight">
                        <Tabs>
                            <telerik:RadTab runat="server" PageViewID="TrainEEPageView" Text="" Font-Bold="true" Value="0" />
                            <telerik:RadTab runat="server" PageViewID="TrainERPageView" Text="" Font-Bold="true" Value="1" />
                        </Tabs>
                    </telerik:RadTabStrip>
                    <telerik:RadMultiPage ID="radMultiExtentPageViews" runat="server" SelectedIndex="0">
                        <telerik:RadPageView ID="TrainEEPageView" runat="server" Height="155px">
                            <div id="multiPageDivTabEE" class="multiPageDivTab" style="height: 350px; overflow: auto; padding:1em;">
                                <div id="JMan2" runat="server">
                                    <fieldset class="otherDataFieldset">
                                        <%--<h3>TrainEE</h3>--%>
                                        <legend>J manoeuvre <img src="../../../../Images/NEDJAG/JAGNED.png" alt="JAG/NED fields"/></legend>
                                        <table id="Table1" runat="server" cellspacing="0" cellpadding="0" border="0">
                                            <tr>
                                                <td style="padding:7px 50px 7px 0px;">
                                                    <asp:RadioButtonList ID="JmanoeuvreRadioButtonList" runat="server" CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" CssClass="rbl" >
                                                        <asp:ListItem Value="1" Text="Not done"></asp:ListItem>
                                                        <asp:ListItem Value="2" Text="Done"></asp:ListItem>
                                                    </asp:RadioButtonList>
                                                </td>
                                                <td>
                                                    <asp:RequiredFieldValidator ID="JmanoeuvreRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                                                                ControlToValidate="JmanoeuvreRadioButtonList" EnableClientScript="true" Display="Dynamic"
                                                                                ErrorMessage="TrainEE : Was J manoeuvre carried out?" Text="*" ToolTip="This is a required field- TrainEE"
                                                                                ValidationGroup="Save" Enabled="True"></asp:RequiredFieldValidator>
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </div>

                                <fieldset class="otherDataFieldset" style="margin-top:20px;" >
                                        <legend>Completion of OGD</legend>
                                        <table cellspacing="0" cellpadding="0" style="padding-top:7px;">
                                            <tr>
                                                <td>
                                                    <asp:RadioButton ID="SuccessfulRadioButton" runat="server" Text="Successful intubation and completion of OGD to" 
                                                        GroupName="TraineeMainOptions" onchange="ToggleControlsTrainee();"/>
                                                    &nbsp;&nbsp;</td>
                                                <td>
                                                    <telerik:RadComboBox ID="ExtentComboBox" runat="server" Skin="Office2007">
                                                    </telerik:RadComboBox>
                                                    <asp:RequiredFieldValidator ID="ExtentRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                                        ControlToValidate="ExtentComboBox" EnableClientScript="true" Display="Dynamic"
                                                        ErrorMessage="Please specify the extent to which the procedure was successful." Text="*" ToolTip="This is a required field"
                                                        ValidationGroup="Save">
                                                    </asp:RequiredFieldValidator>
                                                </td>
                                            </tr>
                                        </table>
                                        <table id="FailedTable" runat="server" cellspacing="0" cellpadding="0" border="0" style="padding-bottom:7px;">
                                            <tr>
                                                <td colspan="2" style="height: 10px;"></td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:RadioButton ID="FailedRadioButton" runat="server" Text="Failed to complete due to" 
                                                        GroupName="TraineeMainOptions" onchange="ToggleControlsTrainee();"/>
                                                    &nbsp;&nbsp;</td>
                                                <td>
                                                    <asp:RadioButton ID="AbandonedRadioButton" runat="server" Text="abandoned" GroupName="TraineeFailedOptions" onchange="ToggleValidatorTrainee();"/>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td></td>
                                                <td>
                                                    <asp:RadioButton ID="FailedIntubationRadioButton" runat="server" Text="failed intubation" GroupName="TraineeFailedOptions" onchange="ToggleValidatorTrainee();"/>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td></td>
                                                <td>
                                                    <asp:RadioButton ID="OesoStrictureRadioButton" runat="server" Text="oesophageal stricture" GroupName="TraineeFailedOptions" onchange="ToggleValidatorTrainee();"/>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td></td>
                                                <td>
                                                    <asp:RadioButton ID="FailedOtherRadioButton" runat="server" Text="other" GroupName="TraineeFailedOptions" onchange="ToggleValidatorTrainee();"/>
                                                    &nbsp;&nbsp;
                                                    <telerik:RadTextBox ID="FailedOtherTextBox" runat="server" Skin="Office2007" Width="300" />
                                                    <asp:RequiredFieldValidator ID="FailedOtherRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                                        ControlToValidate="FailedOtherTextBox" EnableClientScript="true" Display="Dynamic"
                                                        ErrorMessage="Please specify the reason why the OGD was not completed." Text="*" ToolTip="This is a required field"
                                                        ValidationGroup="Save"></asp:RequiredFieldValidator>
                                                </td>
                                            </tr>
                                        </table>
                                        <div>
                                            <telerik:RadNotification ID="SaveRadNotification" runat="server" Animation="None"
                                                EnableRoundedCorners="true" EnableShadow="true" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
                                                LoadContentOn="PageLoad" TitleIcon="delete" Position="Center" Style="color: blue;"
                                                AutoCloseDelay="70000">
                                                <ContentTemplate>
                                                    <asp:ValidationSummary ID="SaveValidationSummary" runat="server" ValidationGroup="Save" EnableClientScript="true"                                         DisplayMode="BulletList" 
                                                        BorderStyle="None" BackColor="Transparent" CssClass="aspxValidationSummary"></asp:ValidationSummary>
                                                </ContentTemplate>
                                            </telerik:RadNotification>
                                        </div>
                                    </fieldset>
                            </div>
                        </telerik:RadPageView>
                        <telerik:RadPageView ID="TrainERPageView" runat="server">
                            <div id="multiPageDivTabER" class="multiPageDivTab" style="height: 350px; overflow: auto; padding:1em;">
                                <div id="JMan" runat="server">
                                    <fieldset class="otherDataFieldset" >
                                        <%--<h3>TrainER</h3>--%>
                                        <legend>J manoeuvre <img src="../../../../Images/NEDJAG/JAGNED.png" alt="JAG/NED fields"/></legend>
                                        <table id="Table2" runat="server" cellspacing="0" cellpadding="0" border="0">
                                            <tr>
                                                <td style="padding:7px 50px 7px 0px;">
                                                    <asp:RadioButtonList ID="TrainerJmanoeuvreRadioButtonList" runat="server" CellSpacing="0" CellPadding="0" RepeatDirection="Horizontal" CssClass="rbl" >
                                                        <asp:ListItem Value="1" Text="Not done"></asp:ListItem>
                                                        <asp:ListItem Value="2" Text="Done"></asp:ListItem>
                                                    </asp:RadioButtonList>
                                                </td>
                                                <td>
                                                    <asp:RequiredFieldValidator ID="TrainerJmanoeuvreRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                                                                ControlToValidate="TrainerJmanoeuvreRadioButtonList" EnableClientScript="true" Display="Dynamic"
                                                                                ErrorMessage="TrainER : Was J manoeuvre carried out?" Text="*" ToolTip="This is a required field"
                                                                                ValidationGroup="Save">
                                                    </asp:RequiredFieldValidator>
                                                </td>
                                            </tr>
                                        </table>
                                    </fieldset>
                                </div>    
                                
                                    <fieldset class="otherDataFieldset" style="margin-top:20px;" >
                                        <legend>Completion of OGD</legend>
                                        <table cellspacing="0" cellpadding="0" style="padding-top:7px;">
                                            <tr>
                                                <td>
                                                    <asp:RadioButton ID="TrainerSuccessfulRadioButton" runat="server" Text="Successful intubation and completion of OGD to" 
                                                        GroupName="TrainerMainOptions" onchange="ToggleControlsTrainer();"/>
                                                    &nbsp;&nbsp;</td>
                                                <td>
                                                    <telerik:RadComboBox ID="TrainerExtentComboBox" runat="server" Skin="Office2007">
<%--                                                        <Items>
                                                            <telerik:RadComboBoxItem value="0" Text=""/>
                                                            <telerik:RadComboBoxItem Value="7" Text="Jejunum" />
                                                            <telerik:RadComboBoxItem value="1" Text="D3"/>
                                                            <telerik:RadComboBoxItem value="2" Text="D2"/>
                                                            <telerik:RadComboBoxItem value="3" Text="D1"/>
                                                            <telerik:RadComboBoxItem value="4" Text="Stomach"/>
                                                            <telerik:RadComboBoxItem Value="5" Text="Distal Oesophagus" />
                                                            <telerik:RadComboBoxItem Value="6" Text="Proximal Oesophagus" />
                                                        </Items>--%>
                                                    </telerik:RadComboBox>
                                                    <asp:RequiredFieldValidator ID="TrainerExtentRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                                        ControlToValidate="TrainerExtentComboBox" EnableClientScript="true" Display="Dynamic"
                                                        ErrorMessage="Please specify the extent to which the procedure was successful." Text="*" ToolTip="This is a required field"
                                                        ValidationGroup="Save">
                                                    </asp:RequiredFieldValidator>
                                                </td>
                                            </tr>
                                        </table>
                                        <table id="TrainerFailedTable" runat="server" cellspacing="0" cellpadding="0" border="0" style="padding-bottom:7px;">
                                            <tr>
                                                <td colspan="2" style="height: 10px;"></td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:RadioButton ID="TrainerFailedRadioButton" runat="server" Text="Failed to complete due to" 
                                                        GroupName="TrainerMainOptions" onchange="ToggleControlsTrainer();"/>
                                                    &nbsp;&nbsp;</td>
                                                <td>
                                                    <asp:RadioButton ID="TrainerAbandonedRadioButton" runat="server" Text="abandoned" GroupName="TrainerFailedOptions" onchange="ToggleValidatorTrainer();"/>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td></td>
                                                <td>
                                                    <asp:RadioButton ID="TrainerFailedIntubationRadioButton" runat="server" Text="failed intubation" GroupName="TrainerFailedOptions" onchange="ToggleValidatorTrainer();"/>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td></td>
                                                <td>
                                                    <asp:RadioButton ID="TrainerOesoStrictureRadioButton" runat="server" Text="oesophageal stricture" GroupName="TrainerFailedOptions" onchange="ToggleValidatorTrainer();"/>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td></td>
                                                <td>
                                                    <asp:RadioButton ID="TrainerFailedOtherRadioButton" runat="server" Text="other" GroupName="TrainerFailedOptions" onchange="ToggleValidatorTrainer();"/>
                                                    &nbsp;&nbsp;
                                                    <telerik:RadTextBox ID="TrainerFailedOtherTextBox" runat="server" Skin="Office2007" Width="300" />
                                                    <asp:RequiredFieldValidator ID="TrainerFailedOtherRequiredFieldValidator" runat="server" CssClass="aspxValidator"
                                                        ControlToValidate="TrainerFailedOtherTextBox" EnableClientScript="true" Display="Dynamic"
                                                        ErrorMessage="Please specify the reason why the OGD was not completed." Text="*" ToolTip="This is a required field"
                                                        ValidationGroup="Save">
                                                    </asp:RequiredFieldValidator>
                                                </td>
                                            </tr>
                                        </table>
                                        <%--<div>
                                            <telerik:RadNotification ID="TrainerSaveRadNotification" runat="server" Animation="None"
                                                EnableRoundedCorners="true" EnableShadow="true" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
                                                LoadContentOn="PageLoad" TitleIcon="delete" Position="Center" Style="color: blue;"
                                                AutoCloseDelay="70000">
                                                <ContentTemplate>
                                                    <asp:ValidationSummary ID="TrainerSaveValidationSummary" runat="server" ValidationGroup="Save" EnableClientScript="true"                                         DisplayMode="BulletList" 
                                                        BorderStyle="None" BackColor="Transparent" CssClass="aspxValidationSummary"></asp:ValidationSummary>
                                                </ContentTemplate>
                                            </telerik:RadNotification>
                                        </div>--%>
                                    </fieldset>
                            </div>
                        </telerik:RadPageView>
                    </telerik:RadMultiPage>
                </div>

            </div>
        </telerik:RadPane>
        <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px">
            <div style="height: 10px; margin-left: 10px; padding-top:2px; padding-bottom:2px">
                <telerik:RadButton ID="SaveButton" runat="server" Text="Save & Close" Skin="Web20" OnClientClicked="checkForValidPage" Icon-PrimaryIconCssClass="telerikSaveButton" />
                <telerik:RadButton ID="CancelButton" runat="server" Text="Cancel" Skin="Web20" Icon-PrimaryIconCssClass="telerikCancelButton" />
                 
                
            </div>
            <div style="height:0px; display:none">
                <telerik:RadButton ID="SaveOnly" runat="server" Text="Save" Skin="Web20" OnClick="SaveOnly_Click" style="height:1px; width:1px" />
            </div>
        </telerik:RadPane>
    </telerik:RadSplitter>

    <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" Modal="true">
    </telerik:RadAjaxLoadingPanel>
</asp:Content>

