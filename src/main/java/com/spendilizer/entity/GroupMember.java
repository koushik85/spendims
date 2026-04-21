package com.spendilizer.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "group_member")
public class GroupMember {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "split_group_id", nullable = false)
    private SplitGroup splitGroup;

    @Column(nullable = false, length = 80)
    private String name;

    @Column(length = 100)
    private String email;

    /** Registered user linked to this member slot, or null for unregistered members. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "linked_user_id", nullable = true)
    private User linkedUser;

    public GroupMember() {}

    public GroupMember(SplitGroup splitGroup, String name, String email, User linkedUser) {
        this.splitGroup = splitGroup;
        this.name = name;
        this.email = email;
        this.linkedUser = linkedUser;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public SplitGroup getSplitGroup() { return splitGroup; }
    public void setSplitGroup(SplitGroup splitGroup) { this.splitGroup = splitGroup; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public User getLinkedUser() { return linkedUser; }
    public void setLinkedUser(User linkedUser) { this.linkedUser = linkedUser; }
}
