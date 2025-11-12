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

class EditProductDetails extends StatefulWidget {
  final String productId;
  const EditProductDetails({Key? key, required this.productId}) : super(key: key);

  @override
  State<EditProductDetails> createState() => _EditProductDetailsState();
}

class _EditProductDetailsState extends State<EditProductDetails> {
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
  List imageUrl = [];
  late String userId;
  List<TextFormField> textFormFieldList = [];
  List newTitleList = [];
  List newSubtitleList = [];
  TextEditingController alertTitleController = TextEditingController();
  TextEditingController alertSubtitleController = TextEditingController();
  TextEditingController newTitleController = TextEditingController();
  Map moreDetailsMap = {};
  Map moreDetailsMap2 = {};
  late String title, description, place, price;
  List<String> deletedImagesList = [];

  @override
  Widget build(BuildContext context) {
    userId = auth.currentUser!.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Edit Product",
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
      body: FutureBuilder(
        future: firestore
            .collection("Products")
            .doc(widget.productId)
            .get()
            .then((value) {
              title = value.data()!['Title'];
              description = value.data()!['Description'];
              place = value.data()!['Place'];
              price = value.data()!['Price'];
              moreDetailsMap = value.data()!['Map'];
              imageUrl = value.data()!['Images'];
            }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: AppSpacing.iconXL,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    "Error loading product",
                    style: AppTextStyles.bodyLarge,
                  ),
                ],
              ),
            );
          }

          return Form(
            key: formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Management Section
                        _buildImageManagementSection(),
                        const SizedBox(height: AppSpacing.lg),

                        // Form Fields Section
                        Text(
                          "Product Details",
                          style: AppTextStyles.h3,
                        ),
                        const SizedBox(height: AppSpacing.md),

                        ModernTextField(
                          controller: titleController..text = title,
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
                          controller: descriptionController..text = description,
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

                        ModernTextField(
                          controller: priceController..text = price,
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
                          controller: placeController..text = place,
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
          );
        },
      ),
    );
  }

  Widget _buildImageManagementSection() {
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
            "Manage product images",
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),

          if (imageUrl.isEmpty && images.isEmpty)
            // Empty state
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.divider,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                color: AppColors.background,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      size: AppSpacing.iconXL,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      "No images",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            // Images horizontal scroll
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: imageUrl.length + images.length + 1,
                separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  // Add more button at the end
                  if (index == imageUrl.length + images.length) {
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

                  // Existing network images
                  if (index < imageUrl.length) {
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
                            child: Image.network(
                              imageUrl[index],
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _confirmDeleteImage(index),
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
                  }

                  // New local images
                  final localIndex = index - imageUrl.length;
                  return Stack(
                    children: [
                      Container(
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
                          child: Image.file(
                            File(images[localIndex].path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
                          ),
                          child: Text(
                            "NEW",
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textOnPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              images.removeAt(localIndex);
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
                        onPressed: () => _deleteAdditionalDetail(index),
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
    final bool hasChanges = images.isNotEmpty || deletedImagesList.isNotEmpty;
    
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
                text: hasChanges ? "Save Changes" : "Update",
                type: ModernButtonType.elevated,
                useGradient: true,
                icon: Icons.save,
                onPressed: () {
                  if (images.isEmpty && imageUrl.isEmpty) {
                    Fluttertoast.showToast(msg: "Please add at least one image");
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

  void _confirmDeleteImage(int index) {
    if (imageUrl.length == 1 && images.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: AppSpacing.iconXL,
                  color: AppColors.warning,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  "Cannot Delete",
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  "Product must have at least one image",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                ModernButton(
                  text: "OK",
                  type: ModernButtonType.elevated,
                  useGradient: true,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.delete_outline,
                size: AppSpacing.iconXL,
                color: AppColors.error,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                "Delete Image?",
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "This action cannot be undone",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: ModernButton(
                      text: "Cancel",
                      type: ModernButtonType.outlined,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ModernButton(
                      text: "Delete",
                      type: ModernButtonType.elevated,
                      onPressed: () {
                        Navigator.of(context).pop();
                        deleteImages(index);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteAdditionalDetail(int index) async {
    if (moreDetailsMap.length == 1) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  size: AppSpacing.iconXL,
                  color: AppColors.info,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  "Cannot Delete",
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  "At least one detail field is required",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                ModernButton(
                  text: "OK",
                  type: ModernButtonType.elevated,
                  useGradient: true,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    moreDetailsMap.remove(newTitleList[index]);
    newTitleList.removeAt(index);
    newSubtitleList.removeAt(index);

    await firestore.collection("Products").doc(widget.productId).update({
      "Map": moreDetailsMap,
    });
    await firestore
        .collection("Sellers")
        .doc(userId)
        .collection("Products")
        .doc(widget.productId)
        .update({
      "Map": moreDetailsMap,
    });

    setState(() {});
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
      showLoading();
      
      // Delete removed images from storage
      for (int i = 0; i < deletedImagesList.length; i++) {
        await firebaseStorage.refFromURL(deletedImagesList[i]).delete();
      }
      
      // Upload new images
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
      
      // Update product in Firestore
      await firestore
          .collection("Products")
          .doc(widget.productId)
          .update({
            'Title': titleController.text,
            'Place': placeController.text,
            'Price': priceController.text,
            'Description': descriptionController.text,
            'Images': imageUrl,
          });
      
      // Update seller's product collection
      await firestore
          .collection("Sellers")
          .doc(userId)
          .collection("Products")
          .doc(widget.productId)
          .update({
            'Title': titleController.text,
            'Description': descriptionController.text,
            'Place': placeController.text,
            'Price': priceController.text,
            'Images': imageUrl,
          });
      
      if (!mounted) return;
      
      await Fluttertoast.showToast(msg: "Product updated successfully");
      
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading
      Navigator.of(context).pop(); // Close edit screen
    } catch (e) {
      if (!mounted) return;
      
      await Fluttertoast.showToast(msg: "Update failed: ${e.toString()}");
      
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
                  "Updating product...",
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
                        onPressed: () async {
                          if (alertFormKey.currentState!.validate()) {
                            moreDetailsMap[alertTitleController.text] =
                                alertSubtitleController.text;
                            
                            await firestore
                                .collection("Products")
                                .doc(widget.productId)
                                .update({
                              "Map": moreDetailsMap,
                            });
                            await firestore
                                .collection("Sellers")
                                .doc(userId)
                                .collection("Products")
                                .doc(widget.productId)
                                .update({
                              "Map": moreDetailsMap,
                            });
                            
                            alertTitleController.clear();
                            alertSubtitleController.clear();
                            Navigator.of(context).pop();
                            setState(() {});
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

  void deleteImages(int index) async {
    if (!mounted) return;
    
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
                  "Deleting image...",
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      await firebaseStorage.refFromURL(imageUrl[index]).delete();
      await firestore.collection("Products").doc(widget.productId).update({
        "Images": FieldValue.arrayRemove([imageUrl[index]])
      });
      
      if (!mounted) return;
      
      setState(() {
        imageUrl.removeAt(index);
      });
      
      Navigator.of(context).pop(); // Close loading dialog
    } catch (e) {
      if (!mounted) return;
      
      Navigator.of(context).pop(); // Close loading dialog
      Fluttertoast.showToast(msg: "Failed to delete image");
    }
  }
}
