package com.model2.mvc.web.review;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Vector;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.apache.ibatis.session.SqlSession;
import org.codehaus.jackson.map.ObjectMapper;
import org.codehaus.jackson.type.TypeReference;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.model2.mvc.common.Page;
import com.model2.mvc.common.Search;
import com.model2.mvc.service.domain.Product;
import com.model2.mvc.service.domain.Purchase;
import com.model2.mvc.service.domain.Review;
import com.model2.mvc.service.domain.User;
import com.model2.mvc.service.product.ProductService;
import com.model2.mvc.service.purchase.PurchaseService;
import com.model2.mvc.service.review.ReviewService;

@Controller
@RequestMapping("/review/*")
public class ReviewController {
	@Autowired
	@Qualifier("reviewService")
	ReviewService reviewService;

	public ReviewController() {
		System.out.println(this.getClass());
	}

	@RequestMapping("addPurchase")
	public ModelAndView addPurchase(@ModelAttribute("purchase") Purchase purchase, HttpSession session, @RequestParam("prodNo") int prodNo) throws Exception {
		User user = (User) session.getAttribute("user");
		Product product = new Product();
		product.setProdNo(prodNo);
		
		//puchase 설정
		purchase.setBuyer(user);
		purchase.setPurchaseProd(product);
		purchase.setTranCode("1");
		
		//실행
		reviewService.addPurchase(purchase);
		
		
		return new ModelAndView("forward:/purchase/confirmPurchase.jsp");
	}

	@RequestMapping("getReview")
	public ModelAndView getPurchase(@RequestParam("tranNo") int tranNo) throws Exception {
		System.out.println("\n==>getPurchase Start.........");
		
		Purchase purchase = reviewService.getPurchase(tranNo);
				
		List<String> purchaseList = purchase.toList();
		System.out.println("getPurchaseAction의 getTranCode값 : "+purchase.getTranCode());
		
		ModelAndView modelAndView = new ModelAndView("forward:/purchase/getPurchase.jsp");
		modelAndView.addObject("list", purchaseList);
		modelAndView.addObject("purchase", purchase);
		
		System.out.println("\n==>getPurchase End.........");
		
		return modelAndView;
	}
	
	@RequestMapping(value="listReview")
	public ModelAndView getPurchaseList(@RequestParam(value = "page", defaultValue = "1") int page, 
								  @RequestParam(value = "currentPage", defaultValue= "1") int currentPage,
								  @ModelAttribute Search search, @RequestParam(value="pageSize", defaultValue="0") int pageSize,
								  HttpServletRequest request,HttpSession session) throws Exception {
		
		System.out.println("\n==>listPurchase Start.........");
		
		if(request.getMethod().equals("GET")) {
			currentPage = page;
		}
		
		if(pageSize == 0) {
			pageSize = this.pageSize;
		}
		
		User user = (User)session.getAttribute("user");
		
		//3.DB 접속을 위한 search
		search.setCurrentPage(currentPage);
		search.setPageSize(pageSize);
		search.setUserId(user.getUserId());

		///4.DB에 접속하여 결과값을 Map으로 가져옴
		Map<String, Object> map = reviewService.getPurchaseList(search);

		
		///5.pageView를 위한 객체
		Page resultPage = new Page(currentPage, ((Integer) map.get("totalCount")).intValue(),
				pageUnit, pageSize);
		
		System.out.println("ListPurchaseAction-resultPage : " + resultPage);
		System.out.println("ListPurchaseAction-list.size() : " + ((List)map.get("list")).size());
		
		
		///6.JSP에 출력을 하기위한 설정들
		//title 설정
		String title = "구매 목록 조회";
		
		//colum 설정
		List<String> columList = new ArrayList<String>();
		columList.add("No");
		columList.add("회원ID");
		columList.add("제품이름");
		columList.add("구매수량");
		columList.add("거래상태");
		columList.add("비고");

		// UnitList 설정
		List<Purchase> list = (List<Purchase>) map.get("list");
		for (int i = 0; i < list.size(); i++) {
			list.get(i).setPurchaseProd(productService.getProduct(list.get(i).getPurchaseProd().getProdNo()));
		}
		List unitList = makePurchaseList(currentPage, list, user);

		//출력을 위한 Object
		ModelAndView modelAndView = new ModelAndView("forward:/purchase/listPurchase.jsp");
		modelAndView.addObject("title", title);
		modelAndView.addObject("columList", columList);
		modelAndView.addObject("unitList", unitList);
		modelAndView.addObject("resultPage", resultPage);
		
		String tranNoList= null;
		String prodNoList= null;
		System.out.println("purchaseController-list.size() : " + list.size());
		if(list != null && list.size() > 0) {
			tranNoList = String.valueOf(list.get(0).getTranNo());
			prodNoList = String.valueOf(list.get(0).getPurchaseProd().getProdNo());
			for (int i = 1; i < list.size(); i++) {
				tranNoList += "," + list.get(i).getTranNo();
				prodNoList += "," + list.get(i).getPurchaseProd().getProdNo();
			}
			modelAndView.addObject("tranNoList",tranNoList);
			modelAndView.addObject("prodNoList",prodNoList);
		}

		System.out.println("\n==>listPurchase End.........");
		
		return modelAndView;
	}

	
	@RequestMapping("updateReview")
	public ModelAndView updatePurchase(@ModelAttribute Purchase purchase, Map<String,Object> map) throws Exception {
		System.out.println("\n==>updatePurchase Start.........");
			
		reviewService.updatePurchase(purchase);
		
		ModelAndView modelAndView = new ModelAndView("forward:/purchase/getPurchase");
		modelAndView.addObject("tranNo", purchase.getTranNo());
		
		System.out.println("\n==>updatePurchase End.........");
		return modelAndView;
	}

	@RequestMapping("updateReview")
	public ModelAndView updateReview(@RequestParam Review review) throws Exception {
		reviewService.updateReview(review);

		return modelAndView;
	}
	
	@RequestMapping("deleteReview")
	public ModelAndView deleteReview(@RequestParam("tranNo") int tranNo) throws Exception {
		Purchase purchase = new Purchase();
		purchase.setTranNo(tranNo);
		purchase.setTranCode("0");

		reviewService.cancelTranCode(purchase);
		
		return new ModelAndView("forward:/purchase/listPurchase");
	}
	
	@RequestMapping("deleteReview")
	public void deleteCart(@RequestParam("reviewNo") int reviewNo) throws Exception {
		reviewService.deleteReview(reviewNo);
	}
}

