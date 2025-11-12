import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'widgets/modern_button.dart';
import 'widgets/modern_text_field.dart';
import 'theme/app_colors.dart';
import 'constants/app_spacing.dart';
import 'theme/app_text_styles.dart';

class AddProduct extends StatefulWidget {
  final String categoryName;
  const AddProduct({Key? key, required this.categoryName}) : super(key: key);

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController titleController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController placeController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<FormState> alertFormKey = GlobalKey<FormState>();
  List<XFile> images = [];
  List<String> imageUrl = [];
  late String userId, productId;
  List<TextFormField> textFormFieldList = [];
  List newTitleList = [];
  List newSubtitleList = [];
  TextEditingController alertTitleController = TextEditingController();
  TextEditingController alertSubtitleController = TextEditingController();
  TextEditingController newTitleController = TextEditingController();
  Map<String, String> moreDetailsMap = {};
  bool moreDetails = false;
  List buyers = [];
  @override
  Widget build(BuildContext context) {
    userId = auth.currentUser!.uid;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Add Product",
          style: AppTextStyles.h2.copyWith(color: AppColors.textOnPrimary),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
      ),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Upload Section
                    _buildImageUploadSection(),
                    const SizedBox(height: AppSpacing.lg),

                    // Form Fields Section
                    Text(
                      "Product Details",
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    ModernTextField(
                      controller: titleController,
                      labelText: "Title",
                      hintText: "Enter product title",
                      prefixIcon: Icons.title,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter Title";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    ModernTextField(
                      controller: descriptionController,
                      labelText: "Description",
                      hintText: "Describe your product",
                      prefixIcon: Icons.description,
                      keyboardType: TextInputType.multiline,
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter description";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Category Display
                    _buildCategoryDisplay(),
                    const SizedBox(height: AppSpacing.md),

                    ModernTextField(
                      controller: priceController,
                      labelText: "Price",
                      hintText: "Enter price",
                      prefixIcon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter price";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    ModernTextField(
                      controller: placeController,
                      labelText: "Location",
                      hintText: "Enter location",
                      prefixIcon: Icons.location_on,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter place";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Additional Details Section
                    _buildAdditionalDetailsSection(),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Product Images",
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "Add at least one image",
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),

          if (images.isEmpty)
            // Dashed border upload area
            GestureDetector(
              onTap: selectImages,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                  color: AppColors.primary.withValues(alpha: 0.05),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: AppSpacing.iconXL,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        "Tap to add photos",
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            // Selected images horizontal scroll
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length + 1,
                separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  if (index == images.length) {
                    // Add more button
                    return GestureDetector(
                      onTap: selectImages,
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                          color: AppColors.primary.withValues(alpha: 0.05),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              color: AppColors.primary,
                              size: AppSpacing.iconLG,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              "Add More",
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Stack(
                    children: [
                      Container(
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                          border: Border.all(
                            color: AppColors.divider,
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                          child: Image.file(
                            File(images[index].path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              images.removeAt(index);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadow,
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close,
                              color: AppColors.textOnPrimary,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryDisplay() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(
            Icons.category,
            color: AppColors.primary,
            size: AppSpacing.iconMD,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Category",
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2), // Minimal spacing for tight layout
                Text(
                  widget.categoryName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalDetailsSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Additional Details",
                style: AppTextStyles.h3,
              ),
              IconButton(
                onPressed: () => alertBox(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppColors.textOnPrimary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          if (moreDetailsMap.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: moreDetailsMap.length,
              separatorBuilder: (context, index) => const Divider(height: AppSpacing.md),
              itemBuilder: (context, index) {
                newTitleList = moreDetailsMap.keys.toList();
                newSubtitleList = moreDetailsMap.values.toList();

                return Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              newTitleList[index],
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              newSubtitleList[index],
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            moreDetailsMap.remove(newTitleList[index]);
                            newTitleList.removeAt(index);
                            newSubtitleList.removeAt(index);
                            if (newTitleList.isEmpty) {
                              moreDetails = false;
                            }
                          });
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ] else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                "No additional details added",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ModernButton(
                text: "Cancel",
                type: ModernButtonType.outlined,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: ModernButton(
                text: images.isEmpty ? "Add Images" : "Post Product",
                type: ModernButtonType.elevated,
                useGradient: true,
                icon: images.isEmpty ? Icons.add_photo_alternate : Icons.check,
                onPressed: () {
                  if (images.isEmpty) {
                    selectImages();
                  } else {
                    upload();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void selectImages() async {
    if (formKey.currentState!.validate()) {
      List<XFile> selectedImages = await ImagePicker().pickMultiImage();
      if (selectedImages.isNotEmpty) {
        setState(() {
          images.addAll(selectedImages);
        });
      }
    }
  }

  void upload() async {
    if (!mounted) return;
    
    try {
      DateTime dateTime = DateTime.now();
      String? productId;
      showLoading();

      for (int i = 0; i < images.length; i++) {
        Reference reference = firebaseStorage
            .ref()
            .child("Seller Product Images")
            .child(userId)
            .child(images[i].name);
        UploadTask uploadTask = reference.putFile(File(images[i].path));
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});

        await taskSnapshot.ref
            .getDownloadURL()
            .then((value) => imageUrl.add(value));
      }
      
      await firestore
          .collection("Products")
          .add(
            {
              'Title': titleController.text,
              'Place': placeController.text,
              'Price': priceController.text,
              'Description': descriptionController.text,
              'Images': imageUrl,
              'Seller ID': userId,
              'Product ID': "",
              'Posted Date': dateTime.toString(),
              'Map': moreDetailsMap,
              'Buyers': buyers,
              'Category': widget.categoryName,
            },
          )
          .then(
            (value) {
              productId = value.id;
              return firestore
                  .collection("Products")
                  .doc(productId)
                  .update({'Product ID': productId});
            },
          )
          .then(
            (value) => firestore
                  .collection("Sellers")
                  .doc(userId)
                  .collection("Products")
                  .doc(productId)
                  .set(
                {
                  'Title': titleController.text,
                  'Description': descriptionController.text,
                  'Place': placeController.text,
                  'Price': priceController.text,
                  'Images': imageUrl,
                  'Product ID': productId,
                  'Posted Date': dateTime.toString(),
                  'Map': moreDetailsMap,
                  'Category': widget.categoryName,
                },
              ),
          );
      
      if (!mounted) return;
      
      await Fluttertoast.showToast(msg: "Product uploaded successfully");
      
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading
      Navigator.of(context).pop(); // Close add product screen
    } catch (e) {
      if (!mounted) return;
      
      await Fluttertoast.showToast(msg: "Uploading failed: ${e.toString()}");
      
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading
    }
  }

  void showLoading() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: AppSpacing.md),
                Text(
                  "Uploading product...",
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  "Please wait",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void alertBox(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: alertFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add Custom Field",
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ModernTextField(
                    controller: alertTitleController,
                    labelText: "Field Name",
                    hintText: "e.g., Brand, Condition",
                    prefixIcon: Icons.label,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter field name";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ModernTextField(
                    controller: alertSubtitleController,
                    labelText: "Field Value",
                    hintText: "e.g., Samsung, Like New",
                    prefixIcon: Icons.text_fields,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter field value";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ModernButton(
                        text: "Cancel",
                        type: ModernButtonType.text,
                        onPressed: () {
                          alertTitleController.clear();
                          alertSubtitleController.clear();
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      ModernButton(
                        text: "Add",
                        type: ModernButtonType.elevated,
                        useGradient: true,
                        onPressed: () {
                          if (alertFormKey.currentState!.validate()) {
                            setState(() {
                              moreDetailsMap[alertTitleController.text] =
                                  alertSubtitleController.text;
                              moreDetails = true;
                            });
                            alertTitleController.clear();
                            alertSubtitleController.clear();
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
