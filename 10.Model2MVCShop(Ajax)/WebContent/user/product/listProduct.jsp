<%@ page language="java"%>
<%@ page contentType="text/html; charset=EUC-KR"%>
<%@ page pageEncoding="EUC-KR"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- �ڽ��� �� ������ ���� ���� �˼��ְ� -->
    
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>���� ��� ��ȸ</title>

<link rel="stylesheet" href="/css/admin.css" type="text/css">
<script src="http://code.jquery.com/jquery-2.1.4.min.js"></script>
<script type="text/javascript">
$(function(){
	var prodNoList = [${prodNoList}];
	
	$("tr.ct_list_pop td:nth-child(3)").css("color","red");
	$("tr.ct_list_pop td:nth-child(3)").on("click",function(){
		location.href = "/product/getProduct?prodNo="+prodNoList[$($("td",$(this).parent())[0]).text()-1];
	});	
	
	$("#searchKeyword").keydown(function(key){
		if( key.keyCode==13 ){
			fncGetList(${resultPage.currentPage});
		}
	});
	$("#search").on("click",function(){
		fncGetList(${resultPage.currentPage});
	});
	
	$(".sort").on("click",function(){
		fncSortList(${resultPage.currentPage},$(".sort").index($(this)));
	});
	
	$("#unHidding").on("click",function(){
		fncHiddingEmptyStock(${resultPage.currentPage},false);
	});
	$("#hidding").on("click",function(){
		fncHiddingEmptyStock(${resultPage.currentPage},true);
	});
	
	$("#reset").on("click",function(){
		fncResetSearchCondition();
	});
	
	$("select[name=pageSize]").on("change",function(){
		fncGetList(${resultPage.currentPage});
	});
	
	$("#prePage").on("click",function(){
		fncGetList(${resultPage.beginUnitPage-1});
	});
	$(".page").on("click",function(){
		fncGetList($(this).text());
	});
	$("#nextPage").on("click",function(){
		fncGetList(${resultPage.endUnitPage+1});
	});
	
	$("#empty").on("click",function(){
		$("#listPrinter").empty()
		
		$.ajax({url:"../common/listPrinter.jsp",

				success:function(result) {

				$("#listPrinter").html(result);

		}});
		
		$("#div1").load("../common/listPrinter.jsp", function(responseTxt, statusTxt, xhr){

	        if(statusTxt == "success")

	            alert("External content loaded successfully!");
	        	$("#listPrinter").html(responseTxt);

	        if(statusTxt == "error")

	            alert("Error: " + xhr.status + ": " + xhr.statusText);

	    });
	});
	
});

function fncValidationCheck(){
	var result = true;
	
	if(document.detailForm.searchCondition.value != 1 && document.detailForm.searchKeyword.value != null){
		var splitSearchKeyword = document.detailForm.searchKeyword.value.split(',');
		
		if(splitSearchKeyword.length > 2){
			alert(" ','�� �̿��Ͽ� 2���� �������� ������ �ֽʽÿ�");
		}
		for(var i = 0; i < splitSearchKeyword.length; i++){
			if(isNaN(splitSearchKeyword[i])){
				alert("���ڸ� �����մϴ�.")
				result = false;
				break;
			}
			
		}
	}
	
	return result;
}

function fncGetList(currentPage){
// 	document.detailForm.currentPage.value = currentPage;
	$("input[name=currentPage]").val(currentPage);
// 	document.detailForm.menu.value = "${param.menu}";
	$("input[name=menu]").val("${param.menu}");
	
	//�˻� ���� Validation Check
	if(!fncValidationCheck()){
		return;
	}

// 	document.detailForm.submit();
	$("form[name=detailForm]").submit();
}

function fncSortList(currentPage, sortCode){
	$("input[name=currentPage]").val(currentPage);
	$("input[name=menu]").val("${param.menu}");
	$("input[name=sortCode]").val(sortCode);
	
	//�˻� ���� Validation Check
	if(!fncValidationCheck()){
		return;
	}

	$("form").submit();
}

function fncHiddingEmptyStock(currentPage, hiddingEmptyStock){
	$("input[name=currentPage]").val(currentPage);
	$("input[name=menu]").val("${param.menu}");
	$("input[name=hiddingEmptyStock]").val(hiddingEmptyStock);
	
	//�˻� ���� Validation Check
	if(!fncValidationCheck()){
		return;
	}

	$("form").submit();
}


function fncResetSearchCondition(){
	location.href = "/product/listProduct?menu=${param.menu}";
}



function fncUpdateTranCodeByProd(currentPage, prodNo){
	$("input[name=currentPage]").val(currentPage);
	$("input[name=menu]").val("${param.menu}");
	
	//�˻� ���� Validation Check
	if(!fncValidationCheck()){
		return;
	}
	
	var URI = "/purchase/updateTranCodeByProd?page=" + currentPage + "&menu=" + "${param.menu}" + "&prodNo=" + prodNo + "&tranCode=2";
	
	if("${empty search.searchKeyword}" != "true"){
		URI += "&searchCondition=" + "${search.searchCondition}" + "&searchKeyword=" + "${search.searchKeyword}";
	}
	
	location.href = URI;
}


</script>
</head>
<body bgcolor="#ffffff" text="#000000">

<div style="width:98%; margin-left:10px;">

<form name="detailForm" action="/product/listProduct" method="post">

<c:import url="../common/listPrinter.jsp"/>

<table width="100%" border="0" cellspacing="0" cellpadding="0" style="margin-top:10px;">
	<tr>
		<td align="center">
			<input type="hidden" id="currentPage" name="currentPage"/>
			<input type="hidden" id="menu" name="menu" value=""/>
			<input type="hidden" id="sortCode" name="sortCode" value="${search.sortCode}"/>
			<input type="hidden" id="hiddingEmptyStock" name="hiddingEmptyStock" value="${search.hiddingEmptyStock}"/>
			
			<c:import url="../common/pageNavigator.jsp"/>
		</td>
	</tr>
	<tr>
		<td align="center">
			<a href="#" class="sort">��ǰ ��ȣ ��������</a>
			&nbsp;
			<a href="#" class="sort">��ǰ ��ȣ ��������</a>
			&nbsp;
			<a href="#" class="sort">��ǰ �̸� ��������</a>
			&nbsp;
			<a href="#" class="sort">��ǰ �̸� ��������</a>
			&nbsp;
			<a href="#" class="sort">���� ������</a>
			&nbsp;
			<a href="#" class="sort">���� ������</a>
		</td>
	</tr>
	<tr>
		<td align="center">
			<a href="#" id="hidding">������ ��ǰ �����</a>
			&nbsp;
			<a href="#" id="unHidding">��� ��ǰ ����</a>
		</td>
	</tr>
	<tr>
		<td align="center">
			<a href="#" id="reset">�˻� ���� �ʱ�ȭ</a>
		</td>
	</tr>
	<tr>
		<td align="center">
			<a href="#" id="empty">listprinter.empty()</a>
		</td>
	</tr>
</table>
</form>

</div>
</body>
</html>
