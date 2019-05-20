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

	@RequestMapping("addReview")
	public ModelAndView addPurchase(@ModelAttribute Review review) throws Exception {
		reviewService.addReview(review);
		
		return new ModelAndView("forward:/product/getProduct?prodNo="+review.getProdNo());
	}

	
	
	@RequestMapping("listReview")
	public ModelAndView getReviewList(@ModelAttribute Search search) throws Exception {
		Map<String, Object> map = reviewService.getReviewList(search);
		ModelAndView modelAndView = new ModelAndView();
		modelAndView.addObject("list",map.get("list"));
		modelAndView.addObject("totalCount",map.get("totalCount"));
		return modelAndView;
	}

	
	@RequestMapping("updateReview")
	public ModelAndView updateReview(@ModelAttribute Review review) throws Exception {
			
		reviewService.updateReview(review);
		review = reviewService.getReview(review.getReviewNo());
		ModelAndView modelAndView = new ModelAndView("forward:/purchase/getPurchase");
		
		modelAndView.addObject("review", review);
		
		return modelAndView;
	}

	@RequestMapping("deleteReview")
	public ModelAndView deleteReview(@RequestParam("reviewNo") int reviewNo) throws Exception {
		reviewService.deleteReview(reviewNo);
		
		return new ModelAndView("forward:/purchase/listPurchase");
	}
	
	@RequestMapping("deleteReview")
	public void deleteCart(@RequestParam("reviewNo") int reviewNo) throws Exception {
		reviewService.deleteReview(reviewNo);
	}
}

