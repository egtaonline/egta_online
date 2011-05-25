class ExposureController < ApplicationController
  expose(:plural_name) { params[:controller] }
  expose(:single_name) { plural_name.singularize }
  expose(:klass) { single_name.camelize.constantize }
  expose(:entries) { klass.all.page(params[:page]).per(15) }
  expose(:entry) { params[:id] == nil ? klass.new : klass.find(params[:id])}
  expose(:title) { params[:class].titleize }
  expose(:klass_name) { single_name.titleize }
end