<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="Staging.ascx.vb" Inherits="UnisoftERS.Staging" %>

<telerik:RadScriptBlock runat="server">
    <style type="text/css">
       
    </style>
    <script type="text/javascript">

        var stagingCheckBoxIds = "#<%= StagingInvestigationsCheckBox.ClientID %>, #<%= StageCheckBox.ClientID %>, #<%= PerformanceStatusCheckBox.ClientID %>";

        $(window).on('load', function () {

            $(stagingCheckBoxIds).each(function () {
                ToggleTRs($(this));
            });
        });

        $(document).ready(function () {
            $(stagingCheckBoxIds).change(function () {
                ToggleTRs($(this));

                checkboxChanged()
                saveStaging();
            });

            $('#<%=ClinicalGroundsCheckBox.ClientID%>').on('change', function () {
                saveStaging();
            });

            $('#<%=MediastinalSamplingCheckBox.ClientID%>').on('change', function () {
                saveStaging();
            });

            $('#<%=ImagingOfThoraxCheckBox.ClientID%>').on('change', function () {
                saveStaging();
            });

            $('#<%=MetastasesCheckBox.ClientID%>').on('change', function () {
                saveStaging();
            });

            $('#<%=PleuralHistologyCheckBox.ClientID%>').on('change', function () {
                saveStaging();
            });

            $('#<%=BronchoscopyCheckBox.ClientID%>').on('change', function () {
                saveStaging();
            });



            $('#<%=PerformanceStatusTypeRadioButtonList.ClientID%>').on('change', function () {
                saveStaging();
            });


        });

        function ToggleTRs(chkbox) {
            var checked = chkbox.is(':checked');
            var nextRow = chkbox.closest('tr').next('tr');
            if (checked) {
                $(nextRow).show();
            }
            else {
                $(nextRow).hide();
                ClearControls($(nextRow));
            }
        }

        function ClearControls(tableCell) {
            tableCell.find("input:radio:checked").removeAttr("checked");
            tableCell.find("input:checkbox:checked").removeAttr("checked");
            tableCell.find("input:text").val("");

            if (tableCell.find("input:text[id*='StageTComboBox']").length > 0) {
                var stageComboBoxIds = ["<%= StageTComboBox.ClientID %>", "<%= StageNComboBox.ClientID %>", "<%= StageMComboBox.ClientID %>"];
                stageComboBoxIds.forEach(function (id) {
                    var comboBox = $find(id);
                    if (comboBox != null) {
                        comboBox.clearSelection();
                    }
                });
            }
        }

        function RemoveZero(sender, args) {
            var tbValue = sender._textBoxElement.value;
            if (tbValue == "0")
                sender._textBoxElement.value = "";
        }

        function combo_changed(sender, args) {
            saveStaging();
        }

        function saveStaging() {
            console.log(" sve")
            var obj = {};
            obj.procedureId = parseInt(<%= Session(UnisoftERS.Constants.SESSION_PROCEDURE_ID)%>);
            obj.stagingInvestigations = $('#<%=StagingInvestigationsCheckBox.ClientID%>').is(':checked');
            obj.clinicalGrounds = $('#<%=ClinicalGroundsCheckBox.ClientID%>').is(':checked');
            obj.imagingOfThorax = $('#<%=ImagingOfThoraxCheckBox.ClientID%>').is(':checked');
            obj.pleuralHistology = $('#<%=PleuralHistologyCheckBox.ClientID%>').is(':checked');
            obj.mediastinalSampling = $('#<%=MediastinalSamplingCheckBox.ClientID%>').is(':checked');
            obj.metastases = $('#<%=MetastasesCheckBox.ClientID%>').is(':checked');
            obj.bronchoscopy = $('#<%=BronchoscopyCheckBox.ClientID%>').is(':checked');
            obj.stage = $('#<%=StageCheckBox.ClientID%>').is(':checked');
            obj.stageT = ($find("<%= StageTComboBox.ClientID%>").get_selectedItem().get_value() == '') ? 0 : parseInt($find("<%= StageTComboBox.ClientID%>").get_selectedItem().get_value());
            obj.stageN = ($find("<%= StageNComboBox.ClientID%>").get_selectedItem().get_value() == '') ? 0 : parseInt($find("<%= StageNComboBox.ClientID%>").get_selectedItem().get_value());
            obj.stageM = ($find("<%= StageMComboBox.ClientID%>").get_selectedItem().get_value() == '') ? 0 : parseInt($find("<%= StageMComboBox.ClientID%>").get_selectedItem().get_value());
            obj.stageLocation = ($find("<%= TumourLocationComboBox.ClientID%>").get_selectedItem().get_value() == '') ? 0 : $find("<%= TumourLocationComboBox.ClientID%>").get_selectedItem().get_value();
            obj.performanceStatus = $('#<%=PerformanceStatusCheckBox.ClientID%>').is(':checked');
            obj.performanceStatusType = ($('#<%=PerformanceStatusTypeRadioButtonList.ClientID%> input:checked').length > 0 ? $('#<%=PerformanceStatusTypeRadioButtonList.ClientID%> input:checked').val() : null);
            $.ajax({
                type: "POST",
                url: "PreProcedure.aspx/SaveBroncoStaging",
                data: JSON.stringify(obj),
                dataType: "json",
                contentType: "application/json; charset=utf-8",
                success: function () {
                    setRehideSummary();
                },
 
            });
        }



        function checkboxChanged() {
            let stagingInvestigations = $('#<%=StagingInvestigationsCheckBox.ClientID%>').is(':checked');
            let StageCheckBox = $('#<%=StageTComboBox.ClientID%>').is(':checked');
            let PerformanceStatusCheckBox = $('#<%=PerformanceStatusCheckBox.ClientID%>').is(':checked');

            if (stagingInvestigations == false) {
                $('#<%=ClinicalGroundsCheckBox.ClientID%>').prop('checked', false);
                $('#<%=ImagingOfThoraxCheckBox.ClientID%>').prop('checked', false);
                $('#<%=PleuralHistologyCheckBox.ClientID%>').prop('checked', false);
                $('#<%=MediastinalSamplingCheckBox.ClientID%>').prop('checked', false);
                $('#<%=StageMComboBox.ClientID%>').prop('checked', false);
                $('#<%=BronchoscopyCheckBox.ClientID%>').prop('checked', false);
            }

            if (PerformanceStatusCheckBox == false) {

                $('#<%=StageCheckBox.ClientID%> input[type="radio"]').each(function () {
                    $(this).prop('checked', false);
                });

            }

        }
    </script>
</telerik:RadScriptBlock>

<telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>"
    Skin="Metro" Position="Center" BorderColor="Red" AutoCloseDelay="0" Width="400" ContentIcon="warning" ShowCloseButton="true" EnableShadow="true" EnableRoundedCorners="true" />
<div class="control-section-header abnorHeader">Staging</div>
<div class="control-content">
    <table>
        <tr>
            <td>
                <table cellpadding="1" cellspacing="1" style="border-collapse: separate;">
                    <tr>
                        <td>
                            <asp:CheckBox ID="StagingInvestigationsCheckBox" runat="server" Text="Staging Investigations" />
                        </td>
                    </tr>
                    <tr style="display: none;">
                        <td>
                            <div style="margin-left: 30px;">
                                <div style="float: left; width: 200px;">
                                    <asp:CheckBox ID="ClinicalGroundsCheckBox" runat="server" Text="Clinical grounds only" /><br />
                                    <asp:CheckBox ID="MediastinalSamplingCheckBox" runat="server" Text="Mediastinal sampling" />
                                </div>

                                <div style="float: left; width: 250px;">
                                    <asp:CheckBox ID="ImagingOfThoraxCheckBox" runat="server" Text="Cross sectional imaging of thorax" /><br />
                                    <asp:CheckBox ID="MetastasesCheckBox" runat="server" Text="Diagnostic tests for metastases" />
                                </div>

                                <div style="float: right;">
                                    <asp:CheckBox ID="PleuralHistologyCheckBox" runat="server" Text="Pleural cytology / histology" /><br />
                                    <asp:CheckBox ID="BronchoscopyCheckBox" runat="server" Text="Bronchoscopy" />
                                </div>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:CheckBox ID="StageCheckBox" runat="server" Text="Stage" />
                        </td>
                    </tr>
                    <tr style="display: none;">
                        <td>
                          <%--  Added by Ferdowsi--%>
                            <div style="margin-left: 30px;">
                                Location of primary tumour: 
                              <telerik:RadDropDownList ID="TumourLocationComboBox" runat="server" Width="170" Skin="Windows7" OnClientSelectedIndexChanged="combo_changed">
                                  <Items>
                                      <telerik:DropDownListItem Text="" Value="0" />
                                      <telerik:DropDownListItem Text="Oesophagus" Value="1" />
                                      <telerik:DropDownListItem Text="Oesophagogastric junction" Value="2" />
                                      <telerik:DropDownListItem Text="Stomach" Value="3" />
                                  </Items>
                              </telerik:RadDropDownList>
                                T
                                <telerik:RadDropDownList ID="StageTComboBox" runat="server" Width="70" Skin="Windows7" OnClientSelectedIndexChanged="combo_changed">
                                    <Items>
                                        <telerik:DropDownListItem Text="" Value="0" />
                                        <telerik:DropDownListItem Text="TX" Value="1" />
                                        <telerik:DropDownListItem Text="T0" Value="2" />
                                        <telerik:DropDownListItem Text="Tis" Value="3" />
                                        <telerik:DropDownListItem Text="T1" Value="4" />
                                        <telerik:DropDownListItem Text="T1a" Value="5" />
                                        <telerik:DropDownListItem Text="T1b" Value="6" />
                                        <telerik:DropDownListItem Text="T2" Value="7" />
                                        <telerik:DropDownListItem Text="T3" Value="8" />
                                        <telerik:DropDownListItem Text="T4" Value="9" />
                                        <telerik:DropDownListItem Text="T4a" Value="10" />
                                        <telerik:DropDownListItem Text="T4b" Value="11" />

                                    </Items>
                                </telerik:RadDropDownList>
                                N
                                <telerik:RadDropDownList ID="StageNComboBox" runat="server" Width="70" Skin="Windows7" OnClientSelectedIndexChanged="combo_changed">
                                    <Items>
                                        <telerik:DropDownListItem Text="" Value="0" />
                                        <telerik:DropDownListItem Text="NX" Value="1" />
                                        <telerik:DropDownListItem Text="N0" Value="2" />
                                        <telerik:DropDownListItem Text="N1" Value="3" />
                                        <telerik:DropDownListItem Text="N2" Value="4" />
                                        <telerik:DropDownListItem Text="N3" Value="5" />

                                    </Items>
                                </telerik:RadDropDownList>
                                M
                                <telerik:RadDropDownList ID="StageMComboBox" runat="server" Width="70" Skin="Windows7" OnClientSelectedIndexChanged="combo_changed">
                                    <Items>
                                        <telerik:DropDownListItem Text="" Value="0" />
                                        <telerik:DropDownListItem Text="MX" Value="1" />
                                        <telerik:DropDownListItem Text="M0" Value="2" />
                                        <telerik:DropDownListItem Text="M1" Value="3" />
                                    </Items>
                                </telerik:RadDropDownList>
                               
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:CheckBox ID="PerformanceStatusCheckBox" runat="server" Text="Performance Status" /><br />
                        </td>
                    </tr>
                    <tr style="display: none;">
                        <td>
                            <div style="margin-left: 30px;">
                                <asp:RadioButtonList ID="PerformanceStatusTypeRadioButtonList" runat="server" CellSpacing="0" CellPadding="0"
                                    RepeatLayout="Table" RepeatDirection="Horizontal" RepeatColumns="3">
                                    <asp:ListItem Value="1" Text="0. normal activity"></asp:ListItem>
                                    <asp:ListItem Value="2" Text="1. able to carry out light work"></asp:ListItem>
                                    <asp:ListItem Value="3" Text="2. unable to carry out any work"></asp:ListItem>
                                    <asp:ListItem Value="4" Text="3. limited self care"></asp:ListItem>
                                    <asp:ListItem Value="5" Text="4. completely disabled"></asp:ListItem>
                                </asp:RadioButtonList>
                            </div>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</div>
