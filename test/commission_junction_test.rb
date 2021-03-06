require 'test_helper'

class CommissionJunctionTest < Test::Unit::TestCase
  def test_new_cj_with_no_params
    assert_raise ArgumentError do
      CommissionJunction.new
    end
  end

  def test_new_cj_with_one_param
    assert_raise ArgumentError do
      CommissionJunction.new('fake')
    end
  end

  def test_new_cj_with_nil_param
    assert_raise ArgumentError do
      CommissionJunction.new(nil, 'website_id')
    end

    assert_raise ArgumentError do
      CommissionJunction.new('developer_key', nil)
    end

    assert_raise ArgumentError do
      CommissionJunction.new('developer_key', 'website_id', nil)
    end
  end

  def test_new_cj_with_empty_param
    assert_raise ArgumentError do
      CommissionJunction.new('', 'website_id')
    end

    assert_raise ArgumentError do
      CommissionJunction.new('developer_key', '')
    end
  end

  def test_new_cj_with_non_string_param
    assert_raise ArgumentError do
      CommissionJunction.new(123456, 'website_id')
    end

    assert_nothing_raised ArgumentError do
      CommissionJunction.new('developer_key', 123456)
    end
  end

  def test_new_cj_with_non_fixnum_timeout
    assert_raise ArgumentError do
      CommissionJunction.new('developer_key', 'website_id', '10')
    end
  end

  def test_new_cj_with_non_positive_timeout
    assert_raise ArgumentError do
      CommissionJunction.new('developer_key', 'website_id', 0)
    end

    assert_raise ArgumentError do
      CommissionJunction.new('developer_key', 'website_id', -1)
    end
  end

  def test_new_cj_with_correct_types
    assert_nothing_raised do
      assert_instance_of(CommissionJunction, CommissionJunction.new('developer_key', 'website_id'))
    end

    assert_nothing_raised do
      assert_instance_of(CommissionJunction, CommissionJunction.new('developer_key', 'website_id', 50))
    end
  end

  def test_new_product_with_no_params
    assert_raise ArgumentError do
      CommissionJunction::Product.new
    end
  end

  def test_new_product_with_nil_params
    assert_raise ArgumentError do
      CommissionJunction::Product.new(nil)
    end
  end

  def test_new_product_with_empty_params
    assert_raise ArgumentError do
      CommissionJunction::Product.new({})
    end
  end

  def test_new_product_with_non_hash_params
    assert_raise ArgumentError do
      CommissionJunction::Product.new([1, 2, 3])
    end
  end

  def test_new_product_with_hash_params_and_non_string_keys
    assert_raise ArgumentError do
      CommissionJunction::Product.new(:name => 'blue jeans', :price => '49.95')
    end
  end

  def test_new_product_with_hash_params_and_string_keys
    assert_nothing_raised do
      product = CommissionJunction::Product.new('name' => 'blue jeans', 'price' => '49.95')
      assert_instance_of(CommissionJunction::Product, product)
      assert_respond_to(product, :name)
      assert_equal('blue jeans', product.name)
      assert_respond_to(product, :price)
      assert_equal('49.95', product.price)
    end
  end

  def test_product_search_with_no_params
    assert_raise ArgumentError do
      CommissionJunction.new('developer_key', 'website_id').product_search
    end
  end

  def test_product_search_with_nil_params
    assert_raise ArgumentError do
      CommissionJunction.new('developer_key', 'website_id').product_search(nil)
    end
  end

  def test_product_search_with_empty_params
    assert_raise ArgumentError do
      CommissionJunction.new('developer_key', 'website_id').product_search({})
    end
  end

  def test_product_search_with_non_hash_params
    assert_raise ArgumentError do
      CommissionJunction.new('developer_key', 'website_id').product_search([1, 2, 3])
    end
  end

  def test_product_search_with_bad_key
    cj = CommissionJunction.new('bad_key', 'website_id')

    assert_raise ArgumentError do
      cj.product_search('keywords' => '+some +product')
    end
  end

  def test_product_search_with_keywords_non_live
    cj = CommissionJunction.new('developer_key', 'website_id')

    assert_nothing_raised do
      cj.product_search('keywords' => '+blue +jeans', 'records-per-page' => '2')
    end

    check_search_results(cj)

    assert_equal(10726, cj.total_matched)
    assert_equal(2, cj.records_returned)
    assert_equal(1, cj.page_number)

    assert_equal('Rockstar Motocross Jeans Blue', cj.cj_objects.first.name)
    assert_equal('Buy Rockstar Motocross Jeans Blue at BlueBee.com', cj.cj_objects.first.description)
    assert_equal('http://www.bluebee.com/cImages/Website_0/type_236/RST01233_255266.jpg', cj.cj_objects.first.image_url.strip)
    assert_equal('209.0', cj.cj_objects.first.price)

    assert_equal('***James Jeans*** Twiggy Aged Blue', cj.cj_objects.last.name)
    assert_equal('Buy ***James Jeans*** Twiggy Aged Blue at BlueBee.com', cj.cj_objects.last.description)
    assert_equal('http://www.bluebee.com/cImages/Website_0/type_236/JME01383_263394.jpg', cj.cj_objects.last.image_url.strip)
    assert_equal('163.0', cj.cj_objects.last.price)
  end

 # def test_product_search_with_keywords_live
 #   key_file = File.join(ENV['HOME'], '.commission_junction.yaml')

 #   unless File.exist?(key_file)
 #     warn "Warning: #{key_file} does not exist. Put your CJ developer key and website ID in there to enable live testing."
 #   else
 #     credentials = YAML.load(File.read(key_file))
 #     cj = CommissionJunction.new(credentials['developer_key'], credentials['website_id'])

 #     # Zero results
 #     assert_nothing_raised do
 #       cj.product_search('keywords' => 'no_matching_results')
 #     end

 #     check_search_results(cj)

 #     # One result
 #     assert_nothing_raised do
 #       cj.product_search('keywords' => '+blue +jeans', 'records-per-page' => '1')
 #     end

 #     check_search_results(cj)

 #     # Multiple results
 #     assert_nothing_raised do
 #       cj.product_search('keywords' => '+blue +jeans', 'records-per-page' => '2')
 #     end

 #     check_search_results(cj)

 #     # Short timeout
 #     cj = CommissionJunction.new(credentials['developer_key'], credentials['website_id'], 1)

 #     assert_nothing_raised do
 #       cj.product_search('keywords' => 'One Great Blue Jean~No Limits', 'records-per-page' => '1')
 #     end

 #     check_search_results(cj)
 #   end
 # end

  def check_search_results(results)
    assert_instance_of(Fixnum, results.total_matched)
    assert_instance_of(Fixnum, results.records_returned)
    assert_instance_of(Fixnum, results.page_number)
    assert_instance_of(Array, results.cj_objects)

    results.cj_objects.each do |product|
      assert_instance_of(CommissionJunction::Product, product)
      assert_respond_to(product, :ad_id)
      assert_respond_to(product, :advertiser_id)
      assert_respond_to(product, :advertiser_name)
      assert_respond_to(product, :buy_url)
      assert_respond_to(product, :catalog_id)
      assert_respond_to(product, :currency)
      assert_respond_to(product, :description)
      assert_respond_to(product, :image_url)
      assert_respond_to(product, :in_stock)
      assert_respond_to(product, :isbn)
      assert_respond_to(product, :manufacturer_name)
      assert_respond_to(product, :manufacturer_sku)
      assert_respond_to(product, :name)
      assert_respond_to(product, :price)
      assert_respond_to(product, :retail_price)
      assert_respond_to(product, :sale_price)
      assert_respond_to(product, :sku)
      assert_respond_to(product, :upc)
    end
  end

  
  def test_advertiser_search_live
    key_file = File.join(ENV['HOME'], '.commission_junction.yaml')

    unless File.exist?(key_file)
      warn "Warning: #{key_file} does not exist. Put your CJ developer key and website ID in there to enable live testing."
    else
      credentials = YAML.load(File.read(key_file))
      cj = CommissionJunction.new(credentials['developer_key'], credentials['website_id'])


      # One result
      assert_nothing_raised do
        result = cj.advertiser_lookup('advertiser-ids' => 'joined', 'page-number' => '1')
        #The New York Pass
      end

      check_advertiser_lookup_results(cj)

      # Multiple results
      assert_nothing_raised do
        cj.advertiser_lookup('keywords' => '+blue +jeans', 'records-per-page' => '2')
      end

      check_advertiser_lookup_results(cj)

      # Short timeout
      cj = CommissionJunction.new(credentials['developer_key'], credentials['website_id'], 1)

      assert_nothing_raised do
        cj.advertiser_lookup('keywords' => 'One Great Blue Jean~No Limits', 'records-per-page' => '1')
      end

      check_advertiser_lookup_results(cj)
    end
  end

  def check_advertiser_lookup_results(results)
    assert_instance_of(Fixnum, results.total_matched)
    assert_instance_of(Fixnum, results.records_returned)
    assert_instance_of(Fixnum, results.page_number)
    assert_instance_of(Array, results.cj_objects)

    results.cj_objects.each do |advertiser|
      assert_instance_of(CommissionJunction::Advertiser, advertiser)
      assert_respond_to(advertiser, :advertiser_id)
      assert_respond_to(advertiser, :advertiser_name)
      assert_respond_to(advertiser, :language)
      assert_respond_to(advertiser, :link_types)
      assert_respond_to(advertiser, :network_rank)
      assert_respond_to(advertiser, :performance_incentives)
      assert_respond_to(advertiser, :primary_category)
      assert_respond_to(advertiser, :program_url)
      assert_respond_to(advertiser, :relationship_status)
      assert_respond_to(advertiser, :seven_day_epc)
      assert_respond_to(advertiser, :three_month_epc)
    end
  end
  
end
