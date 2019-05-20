package com.model2.mvc.service.review;

import java.util.List;

import com.model2.mvc.common.Search;
import com.model2.mvc.service.domain.Review;

public interface ReviewService {
	public boolean addReview(Review review);
	
	public List<Review> getReviews(Search search);

	public boolean updateReview(Review review);
	
	public boolean deleteReview(int reviewNo);
}
