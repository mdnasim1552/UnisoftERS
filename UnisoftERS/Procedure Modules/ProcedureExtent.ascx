<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="ProcedureExtent.ascx.vb" Inherits="UnisoftERS.ProcedureExtent" %>
<%@ Register Src="~/Procedure Modules/LowerExtent.ascx" TagPrefix="Proc" TagName="ProcedureLowerExtent" %>
<%@ Register Src="~/Procedure Modules/UpperExtent.ascx" TagPrefix="Proc" TagName="ProcedureUpperExtent" %>


<proc:ProcedureLowerExtent id="ProcLowerExtent" runat="server" />
<proc:ProcedureUpperExtent id="ProcUpperExtent" runat="server" />