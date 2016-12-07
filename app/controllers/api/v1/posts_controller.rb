class Api::V1::PostsController < Api::V1::ApiProtectedController
  @@limit = 10

  def index
    current_user  = MemberProfile.find_by_id(params[:member_profile_id]).user
    posts         = Post.post_list(params, current_user)

    return render json: posts
  end

  def show
    post         = Post.find_by_id(params[:id])
    resp_data    = get_post_response(post)
    resp_status  = 1
    resp_message = 'Success'
    resp_errors  = ''

    # common_api_response(resp_data, resp_status, resp_message, resp_errors)
    common_api_response(resp_data, resp_status, resp_message, resp_errors, nil)

  end

  def post_comments
    post         = Post.find_by_id(params[:id])
    resp_data    = post_comments_response(post)
    resp_status  = 1
    resp_message = 'Success'
    resp_errors  = ''

    common_api_response(resp_data, resp_status, resp_message, resp_errors)
  end

  def post_likes
    post         = Post.find_by_id(params[:id])
    resp_data    = post_likes_response(post)
    resp_status  = 1
    resp_message = 'Success'
    resp_errors  = ''

    common_api_response(resp_data, resp_status, resp_message, resp_errors)
  end

  def post_reports
    post         = Post.find_by_id(params[:id])
    resp_data    = post_reports_response(post)
    resp_status  = 1
    resp_message = 'Success'
    resp_errors  = ''

    common_api_response(resp_data, resp_status, resp_message, resp_errors)
  end

  def destroy_post
    post           = Post.find_by_id(params[:id])
    post.is_deleted=true
    post.save!
    resp_data    = ''
    resp_status  = 1
    resp_message = 'Success'
    resp_errors  = ''

    common_api_response(resp_data, resp_status, resp_message, resp_errors)

  end

  def destroy_post_comments
    post_comments            = PostComment.find_by_id(params[:post_comment_id])
    post_comments.is_deleted =true
    post_comments.save!
    resp_data    = ''
    resp_status  = 1
    resp_message = 'Success'
    resp_errors  = ''

    common_api_response(resp_data, resp_status, resp_message, resp_errors)


  end

  def create_post
    current_user = MemberProfile.find_by_id(params[:member_profile_id]).user
    response     = Post.post_create(params, current_user)
    return render json: response
  end


  # Responses

  def posts_response(posts, member_profile=nil)
    if member_profile.present?
      member_profile = member_profile.as_json(
          only:    [:id, :about, :phone, :photo, :country_id, :is_profile_public, :state, :default_group_id],
          include: {
              user:    {
                  only: [:id, :full_name, :email, :username]
              },
              country: {
                  only: [:country_name, :iso]
              }
          }
      )
    end

    posts.as_json(
        only:    [:id, :post_title, :post_description, :datetime, :longitude, :latitude, :location, :post_datetime, :is_post_public],
        methods: [:likes_count, :comments_count, :post_members_counts],
        include: {
            member_profile:       {
                only:    [:id, :photo],
                include: {
                    user: {
                        only: [:id, :full_name, :username]
                    }
                }
            },
            post_videos:          {
                only: [:video_url]
            },
            recent_post_comments: {
                only:    [:id, :post_comment],
                include: {
                    member_profile: {
                        only:    [:id, :photo],
                        include: {
                            user: {
                                only: [:id, :full_name, :username]
                            }
                        }
                    }
                }
            },
            recent_post_likes:    {
                only:    [:id],
                include: {
                    member_profile: {
                        only:    [:id],
                        include: {
                            user: {
                                only: [:id, :email, :username]
                            }
                        }
                    }
                }
            }
        }
    )

    if member_profile.present?
      { member_profile: member_profile, posts: posts }.as_json
    else
      { posts: posts }.as_json
    end
  end

  def get_post_response(post)
    post.as_json(
        only:    [:id, :post_title, :post_description, :datetime, :longitude, :latitude, :location, :post_datetime, :is_post_public],
        methods: [:likes_count, :comments_count, :post_members_counts],
        include: {
            member_profile:       {
                only:    [:id, :photo],
                include: {
                    user: {
                        only: [:id, :full_name, :username]
                    }
                }
            },
            post_videos:          {
                only: [:video_url]
            },
            recent_post_comments: {
                only:    [:id, :post_comment],
                include: {
                    member_profile: {
                        only:    [:id, :photo],
                        include: {
                            user: {
                                only: [:id, :full_name, :username]
                            }
                        }
                    }
                }
            },
            recent_post_likes:    {
                only:    [:id],
                include: {
                    member_profile: {
                        only:    [:id],
                        include: {
                            user: {
                                only: [:id, :email, :username]
                            }
                        }
                    }
                }
            }
        }
    )
  end

  def post_comments_response(post)
    post.as_json(
        only:    [:id, :post_title, :post_description, :datetime, :longitude, :latitude, :location, :post_datetime, :is_post_public],
        methods: [:comments_count],
        include: {
            post_comments: {
                only:    [:id, :post_comment],
                include: {
                    member_profile: {
                        only:    [:id],
                        include: {
                            user: {
                                only: [:id, :email, :username]
                            }
                        }
                    }
                }
            }

        }
    )
  end

  def post_likes_response(post)
    post.as_json(
        only:    [:id, :post_title, :post_description, :datetime, :longitude, :latitude, :location, :post_datetime, :is_post_public],
        methods: [:likes_count],
        include: {
            post_likes: {
                only:    [:id],
                include: {
                    member_profile: {
                        only:    [:id],
                        include: {
                            user: {
                                only: [:id, :email, :username]
                            }
                        }
                    }
                }
            }

        }
    )
  end

  def post_reports_response(post)
    post.as_json(
        only:    [:id, :post_title, :post_description, :datetime, :longitude, :latitude, :location, :post_datetime, :is_post_public],
        methods: [:report_posts_count],
        include: {
            report_posts: {
                only:    [:id, :comment],
                include: {
                    member_profile: {
                        only:    [:id],
                        include: {
                            user: {
                                only: [:id, :email, :username]
                            }
                        }
                    }
                }
            }

        }
    )
  end
end
