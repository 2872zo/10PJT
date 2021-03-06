<%@ page language="java"%>
<%@ page contentType="text/html; charset=EUC-KR"%>
<%@ page pageEncoding="EUC-KR"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- 자신이 산 물건은 현재 상태 알수있게 -->
    
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>구매 목록 조회</title>

<link rel="stylesheet" href="/css/admin.css" type="text/css">
<link rel="stylesheet" href="//code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
<script src="http://code.jquery.com/jquery-1.9.1.js"></script>
<script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>
<script src="../javascript/CommonScript.js"></script>
<script type="text/javascript">
$(function(){
	var prodNoList = [${prodNoList}];
	var prodFileList = [${prodFileList}];

	//제품 상세정보
	$("tr.ct_list_pop td:nth-child(3)").wrapInner("<ins></ins>");
	$("tr.ct_list_pop td:nth-child(3)").on("click",function(){
		location.href = "/product/getProduct?prodNo="+prodNoList[$($("td",$(this).parent())[0]).text()-1];
	});	
	
	//이미지 띄우기
	$( "#dialog" ).dialog({
      autoOpen: false
    });
	$("tr.ct_list_pop td:nth-child(3)").hover(
	function(){
		$(this).css("background","#dcdcdc");
// 		$(this).parent().next().find("td").append("<p id='imgfile'> <img src='../images/uploadFiles/" + prodFileList[$("tr.ct_list_pop td:nth-child(3)").index($(this))] + "' width='200'/> </p>");
		$("#dialog").append("<p id='imgfile'> <img src='../images/uploadFiles/" + prodFileList[$("tr.ct_list_pop td:nth-child(3)").index($(this))] + "' width='200'/> </p>");
		$( "#dialog" ).dialog( "option", "position", { my: "left top", at: "left bottom", of: $(this) } );
		$( "#dialog" ).dialog( "open" );
	},
	function(){
		$( "#dialog" ).dialog( "close" );
		$(this).css("background","");
		$("#imgfile").remove();
	});
	
	
	//search 기능
	$("#searchKeyword").keydown(function(key){
		if( key.keyCode==13 ){
			fncGetList(${resultPage.currentPage});
		}
	});
	$("#search").on("click",function(){
		fncGetList(${resultPage.currentPage});
	});
	
	
	//제품 sorting
	$(".ct_list_b:contains('No')").addClass("sort");
	$(".ct_list_b:contains('상품명')").addClass("sort");
	$(".ct_list_b:contains('가격')").addClass("sort");
	$(".sort").wrapInner("<ins></ins>");
	$(".sort").on("click",function(){
// 		alert($("td.sort").index($(this)));
		var sortCode = $(".sort").index($(this));
		if(sortCode == $("#sortCode").val()){
			sortCode += 2; 
		}
// 		alert(sortCode);
		fncSortList(${resultPage.currentPage},sortCode);
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
	
	$("#searchKeyword").keyup(function(){
		if($("#searchCondition").val() == 1 && $("#searchKeyword").val().length >= 1){			
			GetData("product","prod_name","prod_name",$("#searchKeyword").val(),function(output){
// 				alert("output : " + output + " " + typeof(output));
				var jsonArray = $.parseJSON(output);
// 				alert(jsonArray);
				autoComplete(jsonArray);
			});
		}
	});
	
});


/////////////////////////////////////////////////////


function autoComplete(obj){
// 	alert(obj);
	$("#searchKeyword").autocomplete({
		source : obj
	});	
}

function fncValidationCheck(){
	var result = true;
	
	if(document.detailForm.searchCondition.value != 1 && document.detailForm.searchKeyword.value != null){
		var splitSearchKeyword = document.detailForm.searchKeyword.value.split(',');
		
		if(splitSearchKeyword.length > 2){
			alert(" ','를 이용하여 2개의 범위값을 지정해 주십시오");
		}
		for(var i = 0; i < splitSearchKeyword.length; i++){
			if(isNaN(splitSearchKeyword[i])){
				alert("숫자만 가능합니다.")
				result = false;
				break;
			}
			
		}
	}
	
	return result;
}

function fncGetList(currentPage){
	$("input[name=currentPage]").val(currentPage);
	$("input[name=menu]").val("${param.menu}");
	
	if(!fncValidationCheck()){
		return;
	}

	$("form[name=detailForm]").submit();
}

function fncSortList(currentPage, sortCode){
	$("input[name=currentPage]").val(currentPage);
	$("input[name=menu]").val("${param.menu}");
	$("input[name=sortCode]").val(sortCode);
	
	//검색 조건 Validation Check
	if(!fncValidationCheck()){
		return;
	}

	$("form").submit();
}

function fncHiddingEmptyStock(currentPage, hiddingEmptyStock){
	$("input[name=currentPage]").val(currentPage);
	$("input[name=menu]").val("${param.menu}");
	$("input[name=hiddingEmptyStock]").val(hiddingEmptyStock);
	
	//검색 조건 Validation Check
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
	
	//검색 조건 Validation Check
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
<!-- 	<tr> -->
<!-- 		<td align="center"> -->
<!-- 			<a href="#" class="sort">상품 번호 오름차순</a> -->
<!-- 			&nbsp; -->
<!-- 			<a href="#" class="sort">상품 번호 내림차순</a> -->
<!-- 			&nbsp; -->
<!-- 			<a href="#" class="sort">상품 이름 오름차순</a> -->
<!-- 			&nbsp; -->
<!-- 			<a href="#" class="sort">상품 이름 내림차순</a> -->
<!-- 			&nbsp; -->
<!-- 			<a href="#" class="sort">가격 낮은순</a> -->
<!-- 			&nbsp; -->
<!-- 			<a href="#" class="sort">가격 높은순</a> -->
<!-- 		</td> -->
<!-- 	</tr> -->
	<tr>
		<td align="center">
			<a href="#" id="hidding">재고없는 상품 숨기기</a>
			&nbsp;
			<a href="#" id="unHidding">모든 상품 보기</a>
		</td>
	</tr>
	<tr>
		<td align="center">
			<a href="#" id="reset">검색 조건 초기화</a>
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

<div id="dialog"></div>

</body>
</html>
